class Fluentd
  module Setting
    class OutKafka < Output
      include Common

      relate_to_details

    end
  end
end
