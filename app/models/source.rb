class Source < ActiveRecord::Base
  def self.relate_to_details
    class_eval <<-EOF
      has_one :details, :class_name => "Fluentd::Setting::Detail::#{self.name.split('::').last}Detail", :foreign_key => :source_id
      accepts_nested_attributes_for :details
      default_scope -> { includes(:details) }
      # after_initialize :setup_details
      # 
      # def setup_details
      #   self.details = "Fluentd::Setting::Detail::#{self.name.split('::').last}Detail".constantize.new
      # end

      DETAILS_CLASS = "Fluentd::Setting::Detail::#{self.name.split('::').last}Detail".constantize
    EOF
  end

  has_one :agent

  TYPES = {
      twitter: Fluentd::Setting::Detail::InTwitter,
      tail: Fluentd::Setting::Detail::OutWebhdfs
  }

  TYPES_BASE = {
      'Fluentd::Setting::InTwitter' => 'twitter',
      'Fluentd::Setting::InTail' => 'tail',
  }


  ###
  def source_type_name
    return TYPES_BASE[self.type]
  end

end
