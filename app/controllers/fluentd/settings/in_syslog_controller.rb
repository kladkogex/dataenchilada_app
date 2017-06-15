class Fluentd::Settings::InSyslogController < ApplicationController
  include SettingConcern
  before_action :set_agents_tab

  private

  def target_class
    Fluentd::Setting::InSyslog
  end
end
