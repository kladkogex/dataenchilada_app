class Fluentd
  module Setting

    #
    SourceField = Struct.new(:id, :name, :title, :description, :default_val, :type, :advanced) do
      def to_hash_full
        {
            id: id,
            name: name,
            title: title,
            description: description,
            version: version,
            default: default,
        }
      end
    end

    class InSql < Source

      relate_to_details

      TABLES_CLASS = InSqlTable

      has_many :tables, foreign_key: "source_id", class_name: TABLES_CLASS
      # include ActiveModel::Model
      include Common


      # todo
      FIELDS = [
        [1, :host, 'Host', nil, nil, { type: 'text' }, false],
        [2, :port, 'Port', nil, nil, { type: 'text' }, false],
        [3, :database, 'Database', nil, nil, { type: 'text' }, false],
        [4, :adapter, 'Adapter', nil, nil, { type: 'dropdown', values: ['mysql', 'pg'] }, false],
        [5, :username, 'Username', nil, nil, { type: 'text' }, false],
        [6, :password, 'Password', nil, nil, { type: 'text' }, false],
        [7, :select_interval, 'Select interval', nil, nil, { type: 'text' }, true],
        [8, :select_limit, 'Select limit', nil, nil, { type: 'text' }, true],
        [9, :state_file, 'State file', nil, nil, { type: 'hidden' }, true],
        [10, :table, 'Table', nil, nil, { type: 'obj' }, true],
      ].freeze


      KEYS = [
          :host,
          :port,
          :database,
          :adapter,
          :username,
          :password,
          # :tag_prefix,
          :select_interval,
          :select_limit,
          :state_file,
          :table,
          # :all_tables
      ].freeze
      #
      # attr_accessor(*KEYS)

      def self.initial_params
        {
            host: 'localhost',
            database: 'rdb_database',
            adapter: 'mysql2',
            username: 'myusername',
            password: 'mypassword',
            # tag_prefix: 'my.rdb',
            select_interval: '60s',
            select_limit: '500',
            state_file: "/tmp/data_enchilada-sql-#{Time.now.to_i}.pos"
        }
      end

      def self.initial_table_params
        {
            table: 'rdb_table',
            # tag: 'rdb_table_tag',
            update_column_val: 'updated_at',
            time_column: 'updated_at',
            primary_key: ''
        }
      end

      def fields_descriptions
        {
            #host: '* RDBMS host (required)',
            #port: 'RDBMS port (optional)',
            #database: '* RDBMS database name (required)',
            #adapter: '* RDBMS driver name. You should install corresponding gem before start (mysql2 gem for mysql2 adapter, pg gem for postgresql adapter, etc. (required)',
            #username: '* RDBMS login user name (required)',
            #password: '* RDBMS login password (required)',
            # tag_prefix: 'prefix of tags of events. actual tag will be this_tag_prefix.tables_tag (optional, but recommended)',
            select_interval: 'interval to run SQL queries',
            select_limit: 'LIMIT of number of rows for each SQL',
            state_file: '* path to a file to store last rows (required)',
            # all_tables: 'reads all tables instead of configuring each tables in &lt;table&gt; sections (optional)',
        }
      end

      def common_options
        [
            :host,
            :port,
            :database,
            :adapter,
            :username,
            :password,
            # :tag_prefix
        ]
      end

      def advanced_options
        [
            :select_interval,
            :select_limit,
            :state_file
        ]
      end


      def fields_types
        {
            adapter: {type: 'dropdown', values: ['mysql', 'pg']},
            state_file: {type: 'hidden'}
        }
      end


      def table=(value)
        @tables = value.map do |t|
          t.map{|field, value| ([field.to_sym, value] if table_fields.include?(field.to_sym))}.to_h
        end
      end

      def table
        @tables
      end

      def table_fields
        [
            :table,
            :tag,
            :update_column,
            :time_column,
            :primary_key
        ]
      end

      def self.default_tag
        'type_expected_db_table_tag'
      end

      def to_config
        indent = "  "
        config = "<source>\n"
        config << "#{indent}type #{plugin_type_name}\n"
        self.class.const_get(:KEYS).each do |key|
          next if key == :table
          # next if key == :all_tables
          config << indent
          config << conf(key)
          config << "\n"
        end
        tables = send(:table).reject{|t| t.values.join('') == ''} rescue []
        # if tables.present? #&& all_tables != '1'
        tables.each do |tab|
          config << "\n"
          config << indent
          config << "<table>\n"
          tab.each do |key, value|
            config << indent
            config << indent
            config << "#{key} #{value}"
            config << "\n"
          end
          config << indent
          config << "</table>\n"
        end
        # else
        #   config << indent
        #   config << 'all_tables'
        #   config << "\n"
        # end


        config << "</source>\n"
        config.gsub(/^[ ]*\n/m, "")
      end

      def self.create_from_config config
        @setting = {}
        @tables = []
        table = {}
        to_table = false
        str_params = config.split("\r\n").map{|str| str.squish}
        str_params.each do |str|
          case str
            when '<source>', '</source>'
              next
            when '<table>'
              to_table = true
            when '</table>'
              to_table = false
              @tables << table
              table = {}
            # when 'all_tables'
            #   @setting[:all_tables] = true
            else
              param = str.split(' ')
              if to_table
                table[param.first] = param.second
              else
                @setting[param.first] = param.second unless param.first == 'type'
              end
          end
          if @tables.present?
            @setting[:table] = @tables
          end
        end
        self.new @setting
      end

      def plugin_name
        "sql"
      end
    end
  end
end
