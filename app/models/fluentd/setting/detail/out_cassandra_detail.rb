class Fluentd
  module Setting
    module Detail
      class OutCassandraDetail < ActiveRecord::Base
        belongs_to :output
      end
    end
  end
end
