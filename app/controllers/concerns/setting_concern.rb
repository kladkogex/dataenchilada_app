module SettingConcern
  extend ActiveSupport::Concern

  included do
    before_action :login_required
    before_action :find_fluentd
    helper_method :target_plugin_name, :plugin_setting_form_action_url
  end


  def show
    @setting = target_class.new.details.new(initial_params)
    render "shared/settings/show"
  end

  def finish
    @setting = target_class.new(setting_params)
    unless @setting.valid?
      return render "shared/settings/show"
    end

    @fluentd.agent.config_append @setting.to_config
    if @fluentd.agent.running?
      unless @fluentd.agent.restart
        @setting.errors.add(:base, @fluentd.agent.log.tail(1).first)
        @config = Fluentd::Setting::Config.new(@fluentd.config_file)
        @section_id = element_id(Fluent::Config::V1Parser.parse(@setting.to_config, @fluentd.config_file).elements.first)
        return render "shared/settings/edit"
      end
    end
    redirect_to source_daemon_setting_path(@fluentd)
  end

  private

  def setting_params
    params.require(target_class.to_s.underscore.gsub("/", "_")).permit(*target_class.const_get(:KEYS))
  end

  def initial_params
    target_class.initial_params
  end

  def target_plugin_name
    target_class.to_s.split("::").last.underscore
  end

  def plugin_setting_form_action_url(*args)
    send("finish_daemon_setting_#{target_plugin_name}_path", *args)
  end
end
