module SettingConcern
  extend ActiveSupport::Concern

  include OutputConcern

  included do
    before_action :login_required
    # before_action :find_fluentd
    helper_method :target_plugin_name, :plugin_setting_form_action_url
    skip_before_filter :verify_authenticity_token
  end


  def show
    # @setting = target_class.new
    @agent = Agent.new
    @agent.title = 'My agent name'
    @agent.tag = target_class.default_tag
    @agent.source = target_class.new
    @agent.source.details = target_class::DETAILS_CLASS.new(target_class.initial_params)
    render "shared/settings/show"
  end

  def finish
    @agent = Agent.new(agent_params)
    source = target_class.new
    @agent.name = source.plugin_name
    @agent.agent_type = AgentType.find_by(name: 'fluentd')
    details = target_class::DETAILS_CLASS.new(setting_params)

    get_outputs

    unless @agent.valid? && details.valid? && get_outputs.present?
      @agent.source = source
      @agent.source.details = details

      return render "shared/settings/show"
    end

    @agent.save!
    @agent.source = source
    @agent.source.details = details
    @agent.source.details.save!
    @agent.outputs = get_outputs

    # @fluentd.agent.config_append @setting.to_config
    # if @fluentd.agent.running?
    #   unless @fluentd.agent.restart
    #     @setting.errors.add(:base, @fluentd.agent.log.tail(1).first)
    #     @config = Fluentd::Setting::Config.new(@fluentd.config_file)
    #     @section_id = element_id(Fluent::Config::V1Parser.parse(@setting.to_config, @fluentd.config_file).elements.first)
    #     return render "shared/settings/edit"
    #   end
    # end
    redirect_to agents_path
  end

  private

  def agent_params
    params.require('agent').permit(:title, :tag)
  end

  def setting_params
    params.require('agent').require('source').permit(*target_class.const_get(:KEYS))
  end

  def target_plugin_name
    target_class.to_s.split("::").last.underscore
  end

  def plugin_setting_form_action_url(*args)
    send("finish_daemon_setting_#{target_plugin_name}_path", *args)
  end
end
