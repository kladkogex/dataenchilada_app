class Fluentd
  module Setting
    class OutKassandra < Output
      include Common

      relate_to_details

    end
  end
end
