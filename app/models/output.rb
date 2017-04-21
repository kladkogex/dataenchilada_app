class Output < ActiveRecord::Base
  def self.relate_to_details
    class_eval <<-EOF
      has_one :details, :class_name => "Fluentd::Setting::Detail::#{self.name.split('::').last}Detail", :foreign_key => :output_id
      accepts_nested_attributes_for :details
      default_scope -> { includes(:details) }
      
      DETAILS_CLASS = "Fluentd::Setting::Detail::#{self.name.split('::').last}Detail".constantize

      belongs_to :agent
    EOF
  end

  has_one :agent

  OUTPUT_TYPES = {
      kafka: Fluentd::Setting::Detail::OutKafka,
      elasticsearch: Fluentd::Setting::Detail::OutElasticsearch,
      kassandra: Fluentd::Setting::Detail::OutKassandra,
      #hdfs: Fluentd::Setting::Detail::OutWebhdfs
  }

  TYPES_BASE = {
      'Fluentd::Setting::OutKafka' => 'kafka',
      'Fluentd::Setting::OutKassandra' => 'cassandra',
      'Fluentd::Setting::OutElasticsearch' => 'elasticsearch',
  }

  def output_type_name
    return TYPES_BASE[self.type]
  end

end
