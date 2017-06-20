class Fluentd
  module Setting
    class InSqlTable < ActiveRecord::Base
      belongs_to :source

      KEYS = [:table, :update_column_val, :time_column, :primary_key]

      def fields_descriptions
        {
          # tag: 'tag name of events (optional; default value is table name)',
          #table: '* RDBM table name',
          #update_column_val: '* see above description',
          time_column: "Use this filed as the event time. Otherwise current time is used.",
          primary_key: "If update_column is not set, primary key will be used."
        }
      end

      def fields_titles
        {
            table: 'Table name',
            update_column_val: 'Update column',
            time_column: 'Time column',
            primary_key: 'Primary key'
        }
      end


    end
  end
end
