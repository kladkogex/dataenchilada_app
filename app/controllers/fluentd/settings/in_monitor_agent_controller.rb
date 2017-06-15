class Fluentd::Settings::InMonitorAgentController < ApplicationController
  include SettingConcern
  before_action :set_agents_tab

  private

  def target_class
    Fluentd::Setting::InMonitorAgent
  end
end
