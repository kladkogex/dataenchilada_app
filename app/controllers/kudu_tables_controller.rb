class KuduTablesController < ApplicationController

  def index
    @items = get_kudu_tables
    # for test
    #@items = KuduTable.all
  end

  def show
    @name = params[:name]
    @table_from_kudu = get_columns_form_table(@name)
    # for test
    #@table_columns = KuduTable.where(name: @name).first.columns
  end

  def new
    @table = KuduTable.new
    @types = KuduTableColumns::TYPES
  end

  def edit
    @name = params[:name]
    @table = KuduTable.where(name: @name).first
    @types = KuduTableColumns::TYPES
  end

  def create
    table_name = params[:kudu_table][:name]
    columns_attributes_hash = params[:kudu_table][:columns_attributes]

    res = KuduTable.new(table_params)
    res.save

    respond_to do |format|
      if res
        data = get_data_for_table(table_name, columns_attributes_hash)
        kudu_create_table(data)
        format.html { redirect_to kudu_tables_path, notice: "table #{table_name} was created" }
        format.js   { }
      else
        format.html { render :new }
        format.js   { }
      end
    end
  end

  def update
    table_name_after = params[:kudu_table][:name]
    columns_attributes_hash = params[:kudu_table][:columns_attributes]
    @table_name_before = params[:name]
    @table = KuduTable.where(name: @table_name_before).first

    res = @table.update(table_params)

    respond_to do |format|
      if res
        #data = get_data_for_table(table_name, columns_attributes_hash)
        #kudu_create_table(data)
        format.html { redirect_to kudu_tables_path, notice: "table #{table_name_after} was updated" }
        format.js   { }
      else
        format.html { render :new }
        format.js   { }
      end
    end
  end

  private

  def table_params
    params.require(:kudu_table).permit(:name, columns_attributes: [:id, :name, :type_name, :primary_key, :_destroy])
  end

  def get_kudu_tables
    impala_host, impala_port = get_impala_address
    Dataenchilada::Agents::CreateKuduTable.get_tables(impala_host, impala_port)
  end

  def get_columns_form_table(table_name)
    impala_host, impala_port = get_impala_address
    Dataenchilada::Agents::CreateKuduTable.get_columns(impala_host, impala_port, table_name)
  end

  def kudu_create_table(data)
    impala_host, impala_port = get_impala_address
    Dataenchilada::Agents::CreateKuduTable.create_custom_table(impala_host, impala_port, data)
  end

  def get_impala_address
    sys_prop = Dataenchilada::Agents::Configurator.get_system_props
    impala_host = sys_prop[:impala_host]
    impala_port = sys_prop[:impala_port] || 21000
    return [impala_host, impala_port]
  end

  def get_data_for_table(table_name, columns_attributes)
    vasya = []
    columns_attributes.each do |k, v|
      vasya << [v['name'], v['type_name'].upcase]
    end
    columns = ""
    vasya.each do |t|
      columns << "#{t.join(' ')}, "
    end
    string = "CREATE TABLE IF NOT EXISTS #{table_name}(kudu_id BIGINT, kudu_processed_at STRING, processed_at STRING, source STRING, #{columns}PRIMARY KEY(kudu_id, kudu_processed_at))
     PARTITION BY HASH PARTITIONS 16
     STORED AS KUDU
     TBLPROPERTIES ( 'kudu.num_tablet_replicas' =  '1', 'kudu.table_name' = '#{table_name}');"
  end


end
