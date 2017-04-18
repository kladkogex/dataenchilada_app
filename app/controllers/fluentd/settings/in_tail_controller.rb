class Fluentd::Settings::InTailController < ApplicationController
  before_action :login_required
  before_action :find_fluentd

  def after_file_choose
    @setting = Fluentd::Setting::InTail.new({
      :path => params[:path],
      :tag => nil,
    })
  end

  def after_format
    # NOTE: pos_file form field doesn't exists before this action
    attrs = setting_params
    if attrs[:pos_file].blank?
      attrs.merge!(pos_file: "/tmp/fluentd-#{@fluentd.id}-#{Time.now.to_i}.pos")
    end
    attrs.merge!(tag: attrs['path'].split('/').last)
    @setting = Fluentd::Setting::InTail.new(attrs)
  end

  def confirm
    @setting = Fluentd::Setting::InTail.new(setting_params)
    if params[:back]
      return render :after_file_choose
    end
    unless @setting.valid?
      return render :after_format
    end
  end

  def finish
    @setting = Fluentd::Setting::InTail.new(setting_params)
    if params[:back]
      return render :after_format
    end

    unless @setting.valid?
      return render "after_format"
    end

    if @fluentd.agent.configuration.to_s.include?(@setting.to_conf.strip)
      @setting.errors.add(:base, :duplicated_conf)
      return render "after_format"
    end

    @fluentd.agent.config_append @setting.to_conf
    @fluentd.agent.restart if @fluentd.agent.running?
    redirect_to source_daemon_setting_path(@fluentd)
  end

  private

  def setting_params
    params.require(:setting).permit(:path, :format, :regexp, *Fluentd::Setting::InTail.known_formats, :tag, :rotate_wait, :pos_file, :read_from_head, :refresh_interval)
  end

end
