class Fluentd::Settings::InTwitterController < ApplicationController
  include SettingConcern
  include SettingEditConcern
  before_action :set_agents_tab

  private

  def target_class
    Fluentd::Setting::InTwitter
  end
end
