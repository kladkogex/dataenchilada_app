class Fluentd::Settings::InTailController < ApplicationController
  before_action :login_required
  # before_action :find_fluentd

  include OutputConcern

  def after_file_choose
    @setting = Fluentd::Setting::InTail.new({
      details: Fluentd::Setting::Detail::InTailDetail.new({
        :path => params[:path]
      })
    })

    q = @setting.details
    @agent_params = agent_params
  end

  def after_format
    # NOTE: pos_file form field doesn't exists before this action
    attrs = setting_params
    if attrs[:pos_file].blank?
      attrs[:details_attributes].merge!(pos_file: "/tmp/fluentd-file-#{Time.now.to_i}.pos")
    end
    # attrs.merge!(tag: attrs['path'].split('/').last)
    @setting = Fluentd::Setting::InTail.new({
      details: Fluentd::Setting::Detail::InTailDetail.new(attrs['details_attributes'])
    })
    @agent_params = agent_params
  end

  def confirm
    @setting = Fluentd::Setting::InTail.new({
        details: Fluentd::Setting::Detail::InTailDetail.new(setting_params['details_attributes'])
    })
    @agent_params = agent_params
    if params[:back]
      return render :after_file_choose
    end
    unless @setting.details.valid?
      return render :after_format
    end
  end

  def finish
    @agent = ::Agent.new(agent_params)
    source = target_class.new
    @agent.name = source.plugin_name
    @agent.agent_type = AgentType.find_by(name: 'fluentd')
    details = target_class::DETAILS_CLASS.new(setting_params_for_finish['details_attributes'])

    # if params[:back]
    #   return render :after_format
    # end

    unless details.valid? && get_outputs_for_local.present?
      return render "after_format"
    end

    @agent.save!
    @agent.source = source
    @agent.source.details = details
    @agent.source.details.save!
    @agent.outputs = get_outputs_for_local

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
          render :manage
        }
        format.json { return_json(@res)  }
      end

    end
    # if @fluentd.agent.configuration.to_s.include?(@setting.to_conf.strip)
    #   @setting.errors.add(:base, :duplicated_conf)
    #   return render "after_format"
    # end
    #
    # @fluentd.agent.config_append @setting.to_conf
    # @fluentd.agent.restart if @fluentd.agent.running?
    # redirect_to source_daemon_setting_path(@fluentd)
  end

  private

  def agent_params
    params.require('agent').permit(:title)
  end

  def setting_params
    #params.require(:agent).require(:details_attributes).permit(:path, :format, :regexp, *Fluentd::Setting::InTail.known_formats, :rotate_wait, :pos_file, :read_from_head, :refresh_interval)
    params.require(:setting).permit!#(details_attributes: [:id, :path, :format, :regexp, *Fluentd::Setting::InTail.known_formats, :rotate_wait, :pos_file, :read_from_head, :refresh_interval])
  end

  def setting_params_for_finish
    params.require(:agent).permit!
  end

  def target_class
    Fluentd::Setting::InTail
  end

  def output_params
    params.require(:agent).require('outputs')
  end

end
