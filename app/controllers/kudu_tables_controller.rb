class KuduTablesController < ApplicationController

  def index
    @items = get_kudu_tables
  end

  def show
    @name = params[:name]
    @table_columns = get_columns_form_table(@name)
  end

  def new
    @kudu = KuduTable.new
    @types = KuduTableColumns::TYPES
  end

  def create

    res = KuduTable.new(table_params)
    res.save

    respond_to do |format|
      if res
        kudu_create_table(params[:name])
        format.html { redirect_to kudus_tables_path, notice: 'table is created' }
        format.js   { }
      else
        format.html { render :new }
        format.js   { }
      end
    end
  end

  private

  def table_params
    params.require(:kudu_table).permit(:name, columns_attributes: [:id, :name, :type])
  end

  def get_kudu_tables
    impala_host, impala_port = get_impala_address
    Dataenchilada::Agents::CreateKuduTable.get_tables(impala_host, impala_port)
  end

  def get_columns_form_table(table_name)
    impala_host, impala_port = get_impala_address
    Dataenchilada::Agents::CreateKuduTable.get_columns(impala_host, impala_port, table_name)
  end

  def kudu_create_table(table_name)
    impala_host, impala_port = get_impala_address
    Dataenchilada::Agents::CreateKuduTable.create_custom_table(impala_host, impala_port, table_name)
  end

  def get_impala_address
    sys_prop = Dataenchilada::Agents::Configurator.get_system_props
    impala_host = sys_prop[:impala_host]
    impala_port = sys_prop[:impala_port] || 21000
    return [impala_host, impala_port]
  end
end
