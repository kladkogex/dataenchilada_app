class KudusController < ApplicationController

  def index
    @items = get_kudu_tables
  end


  def get_kudu_tables
    # get system props
    sys_prop = Dataenchilada::Agents::Configurator.get_system_props
    impala_host = sys_prop[:impala_host]
    impala_port = sys_prop[:impala_port] || 21000
    # get tables list
    Dataenchilada::Agents::CreateKuduTable.get_tables(impala_host, impala_port)
  end

end
