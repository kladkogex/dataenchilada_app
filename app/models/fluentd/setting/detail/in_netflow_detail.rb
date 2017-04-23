class Fluentd
  module Setting
    module Detail
      class InNetflowDetail < ActiveRecord::Base
        belongs_to :source

        validates :bind, presence: true
        validates :port, presence: true
        validates :tag, presence: true
      end
    end
  end
end
