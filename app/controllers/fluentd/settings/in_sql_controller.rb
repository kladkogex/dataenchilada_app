class Fluentd::Settings::InSqlController < ApplicationController
  before_action :login_required
  # before_action :find_fluentd
  skip_before_filter :verify_authenticity_token
  before_action :set_agents_tab

  include SettingEditConcern
  include OutputConcern

  def show
    @agent = ::Agent.new
    @agent.title = 'My agent name'
    @agent.tag = target_class.default_tag
    @agent.source = target_class.new
    @agent.source.details = target_class::DETAILS_CLASS.new(target_class.initial_params)
    @agent.source.tables = [target_class::TABLES_CLASS.new(target_class.initial_table_params)]
  end

  def finish
    @agent = ::Agent.new(agent_params)
    source = target_class.new
    @agent.name = source.plugin_name
    @agent.agent_type = AgentType.find_by(name: 'fluentd')
    details = target_class::DETAILS_CLASS.new(setting_params)
    # @agent.source = target_class.new
    # @agent.source.details = target_class::DETAILS_CLASS.new(setting_params)
    # binding.pry
    # @agent.outputs = get_outputs

    tables = []

    tabless = params[:tables]
    if tabless.is_a? Array
      tabless.each do |t|
        table = target_class::TABLES_CLASS.new.tap do |tab|
          tab.primary_key = t[:primary_key]
          tab.time_column = t[:time_column]
          tab.update_column_val = t[:update_column_val]
          tab.table = t[:table]
        end
        tables << table
      end
    end

    #tables = tables_params

    #tables = target_class::TABLES_CLASS.new(tables_params)

    outputs = get_outputs

    unless @agent.valid? && details.valid? && outputs.present?
      @agent.source = source
      @agent.source.details = details
      #@agent.source.tables = [tables]
      @agent.source.tables = tables

      return render "fluentd/settings/in_sql/show"
    end

    @agent.save!
    @agent.source = source
    @agent.source.details = details
    @agent.source.details.save!
    #@agent.source.tables = [tables]
    @agent.source.tables = tables
    @agent.outputs = outputs


    # @setting = target_class.new(setting_params)
    # unless @setting.valid?
    #   return render "fluentd/settings/in_sql/show"
    # end
    #
    # @fluentd.agent.config_append @setting.to_config
    # if @fluentd.agent.running?
    #   unless @fluentd.agent.restart
    #     @setting.errors.add(:base, @fluentd.agent.log.tail(1).first)
    #     return render "fluentd/settings/in_sql/show"
    #   end
    # end
    # redirect_to source_daemon_setting_path(@fluentd)
    #redirect_to agents_path

    # run agent
    @res = Dataenchilada::Agents::Manager.do_command(@agent, "run")

    #redirect_to agents_path

    # result
    respond_to do |format|
      if @res
        format.html {
          #redirect_to manage_agent_path(@agent), notice: 'Command sent'
          redirect_to agents_path, notice: 'Command sent'
        }
        format.json { return_json(res) }
      else
        format.html {
          flash[:error] = "Something went wrong"
          render "show"
          #render :manage
        }
        format.json { return_json(@res)  }
      end

    end
  end

  private

  # def setting_params
  #   params.require(target_class.to_s.underscore.gsub("/", "_")).permit(:host,
  #                                                                      :port,
  #                                                                      :database,
  #                                                                      :adapter,
  #                                                                      :username,
  #                                                                      :password,
  #                                                                      :tag_prefix,
  #                                                                      :select_interval,
  #                                                                      :select_limit,
  #                                                                      :state_file,
  #                                                                      :all_tables,
  #                                                                      table: [:table,
  #                                                                              :tag,
  #                                                                              :update_column,
  #                                                                              :time_column,
  #                                                                              :primary_key])
  # end

  def tables_params
    params.require(:tables).first.permit([:table, :update_column_val, :time_column, :primary_key])
  end

  def agent_params
    params.require('agent').permit(:title, :tag)
  end

  def setting_params
    params.require('agent').require('source').permit(*target_class.const_get(:KEYS))
  end

  def target_class
    Fluentd::Setting::InSql
  end

  def plugin_setting_form_action_url(*args)
    send("finish_daemon_setting_#{target_plugin_name}_path", *args)
  end
end
