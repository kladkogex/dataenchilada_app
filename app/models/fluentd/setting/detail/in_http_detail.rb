class Fluentd
  module Setting
    module Detail
      class InHttpDetail < ActiveRecord::Base
        belongs_to :source

        validates :bind, presence: true
        validates :port, presence: true
      end
    end
  end
end
