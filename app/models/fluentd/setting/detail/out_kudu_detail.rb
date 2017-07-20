class Fluentd
  module Setting
    module Detail
      class OutKuduDetail < ActiveRecord::Base
        belongs_to :output

        validates :flume_sink_port, presence: true, uniqueness: true
        validates :table_name, presence: true, uniqueness: true
      end
    end
  end
end
