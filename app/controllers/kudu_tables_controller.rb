class KuduTablesController < ApplicationController

  def index
    @items = get_kudu_tables
    # for test
    #@items = KuduTable.all
  end

  def show
    @name = params[:name]
    @table_from_kudu = get_columns_form_table(@name)
    create_if_no_exist_in_db(@name, @table_from_kudu)
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
    # for kudu
    data = set_data_for_table(table_name, columns_attributes_hash)
    kudu_create_table(data)

    #
    res = KuduTable.new(table_params)
    res.save

    respond_to do |format|
      if res
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
    table_name_before = params[:name]
    @table = KuduTable.where(name: table_name_before).first
    # for kudu
    update_delete_column(table_name_before, columns_attributes_hash) if columns_attributes_hash
    update_add_column(table_name_before, columns_attributes_hash) if columns_attributes_hash
    if table_name_before != table_name_after
      rename_query = "ALTER TABLE #{table_name_before} rename to #{table_name_after};"
      kudu_update(rename_query)
    end

    res = @table.update(table_params)

    respond_to do |format|
      if res
        format.html { redirect_to kudu_tables_path, notice: "table #{table_name_after} was updated" }
        format.js   { }
      else
        format.html { render :new }
        format.js   { }
      end
    end
  end

  def destroy
    @table = KuduTable.where(name: params[:name]).first
    delete_table_from_kudu(params[:name])

    res = @table.destroy
    respond_to do |format|
      if res
        format.html { redirect_to kudu_tables_path, notice: "table was dropped" }
        format.js   { }
      else
        format.html { render :edit }
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

  def kudu_update(query)
    impala_host, impala_port = get_impala_address
    Dataenchilada::Agents::CreateKuduTable.update_table_kudu(impala_host, impala_port, query)
  end

  def get_impala_address
    sys_prop = Dataenchilada::Agents::Configurator.get_system_props
    impala_host = sys_prop[:impala_host]
    impala_port = sys_prop[:impala_port] || 21000
    return [impala_host, impala_port]
  end

  def set_data_for_table(table_name, columns_attributes)
    vasya = []
    if columns_attributes
      columns_attributes.each do |k, v|
        vasya << [v['name'], v['type_name'].upcase]
      end
      columns = ""
      vasya.each do |t|
        columns << "#{t.join(' ')}, "
      end
    end

    string = "CREATE TABLE IF NOT EXISTS #{table_name}(kudu_id BIGINT, kudu_processed_at STRING, processed_at STRING, source STRING, #{columns}PRIMARY KEY(kudu_id, kudu_processed_at))
     PARTITION BY HASH PARTITIONS 16
     STORED AS KUDU
     TBLPROPERTIES ( 'kudu.num_tablet_replicas' =  '1', 'kudu.table_name' = '#{table_name}');"
  end

  def update_delete_column(table_name_before, columns_attributes)
    columns_attributes.each do |k, v|
      if v['_destroy'] != "false"
        column_name = KuduTableColumns.find(v['id'].to_i).name
        del_column = "ALTER TABLE #{table_name_before} DROP column #{column_name};"
        # execute
        kudu_update(del_column)
      end
    end
  end

  def update_add_column(table_name_before, columns_attributes)
    vasya = []
    columns_attributes.each do |k, v|
      if !v['name'].blank?
        vasya << [v['name'], v['type_name'].upcase]
      end
    end
    columns = ""
    vasya.each do |t|
      columns << "#{t.join(' ')}, "
    end

    add_query = "ALTER TABLE #{table_name_before} ADD COLUMNS (#{columns.first(-2)})"
    # execute
    kudu_update(add_query) if !columns.blank?
  end

  def create_if_no_exist_in_db(name, table_from_kudu)
    table = KuduTable.where(name: name).first.blank?
    if table
      new_table = KuduTable.new(name: name)
      new_table.save
      table_from_kudu.each do |item|
        columns = KuduTableColumns.new(table_id: new_table.id, name: item['name'], type_name: item['type'])
        columns.save
      end
    end
  end

  def delete_table_from_kudu(table_name)
    del_table = "DROP TABLE #{table_name};"
    kudu_update(del_table)
  end

end
