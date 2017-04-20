class Fluentd
  module Setting
    module Detail
      class OutElasticsearchDetail < ActiveRecord::Base
        belongs_to :output
      end
    end
  end
end
