class Fluentd
  module Setting
    module Detail
      class InTwitterDetail < ActiveRecord::Base
        belongs_to :source

        validates :consumer_key, presence: true
        validates :consumer_secret, presence: true
        validates :access_token, presence: true
        validates :access_token_secret, presence: true
        validates :tag, presence: true
        validates :timeline, presence: true
      end
    end
  end
end
