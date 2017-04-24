class Fluentd::Settings::InSqlController < ApplicationController
  before_action :login_required
  # before_action :find_fluentd

  include SettingEditConcern

  def show
    @agent = ::Agent.new
    @agent.title = 'aggg1'
    @agent.source = target_class.new
    @agent.source.details = target_class::DETAILS_CLASS.new(target_class.initial_params)
    @agent.source.tables = [target_class::TABLES_CLASS.new(target_class.initial_table_params)]
  end

  def finish

    @agent = Agent.new(agent_params)
    source = target_class.new
    @agent.name = source.plugin_name
    details = target_class::DETAILS_CLASS.new(setting_params)
    # @agent.source = target_class.new
    # @agent.source.details = target_class::DETAILS_CLASS.new(setting_params)
    # binding.pry
    # @agent.outputs = get_outputs

    unless details.valid?
      return render "shared/settings/show"
    end

    @agent.save!
    @agent.source = source
    @agent.source.details = details
    @agent.source.details.save!
    @agent.outputs = get_outputs


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
  end

  private

  def setting_params
    params.require(target_class.to_s.underscore.gsub("/", "_")).permit(:host,
                                                                       :port,
                                                                       :database,
                                                                       :adapter,
                                                                       :username,
                                                                       :password,
                                                                       :tag_prefix,
                                                                       :select_interval,
                                                                       :select_limit,
                                                                       :state_file,
                                                                       :all_tables,
                                                                       table: [:table,
                                                                               :tag,
                                                                               :update_column,
                                                                               :time_column,
                                                                               :primary_key])
  end

  def target_class
    Fluentd::Setting::InSql
  end

  def plugin_setting_form_action_url(*args)
    send("finish_daemon_setting_#{target_plugin_name}_path", *args)
  end
end
