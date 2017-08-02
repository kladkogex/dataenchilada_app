class KuduTablesController < ApplicationController

  def index
    @items = get_kudu_tables
    # for test
    #@items = KuduTable.all
  end

  def show
    @name = params[:name]
    @table_columns = get_columns_form_table(@name)
    # for test
    #@table_columns = KuduTable.where(name: @name).first.columns
  end

  def new
    @kudu = KuduTable.new
    @types = KuduTableColumns::TYPES
  end

  def create
    table_name = params[:kudu_table][:name]
    columns_attributes_hash = params[:kudu_table][:columns_attributes]

    res = KuduTable.new(table_params)
    res.save

    respond_to do |format|
      if res
        columns = get_columns_and_types(table_name, columns_attributes_hash)
        kudu_create_table(table_name, columns)
        format.html { redirect_to kudu_tables_path, notice: "table #{table_name} was created" }
        format.js   { }
      else
        format.html { render :new }
        format.js   { }
      end
    end
  end

  private

  def table_params
    params.require(:kudu_table).permit(:name, columns_attributes: [:id, :name, :type_name, :primary_key])
  end

  def get_kudu_tables
    impala_host, impala_port = get_impala_address
    Dataenchilada::Agents::CreateKuduTable.get_tables(impala_host, impala_port)
  end

  def get_columns_form_table(table_name)
    impala_host, impala_port = get_impala_address
    Dataenchilada::Agents::CreateKuduTable.get_columns(impala_host, impala_port, table_name)
  end

  def kudu_create_table(table_name, columns)
    impala_host, impala_port = get_impala_address
    Dataenchilada::Agents::CreateKuduTable.create_custom_table(impala_host, impala_port, table_name, columns)
  end

  def get_impala_address
    sys_prop = Dataenchilada::Agents::Configurator.get_system_props
    impala_host = sys_prop[:impala_host]
    impala_port = sys_prop[:impala_port] || 21000
    return [impala_host, impala_port]
  end

  def get_columns_and_types(table_name, columns_attributes)
    vasya = []
    columns_attributes.each do |k, v|
      vasya << [v['name'], v['type_name'].upcase]
    end
    string_with_names_and_types_of_columns = ""
    vasya.each do |t|
      string_with_names_and_types_of_columns << "#{t.join(' ')},\n          "
    end
    string_with_names_and_types_of_columns
  end
end
