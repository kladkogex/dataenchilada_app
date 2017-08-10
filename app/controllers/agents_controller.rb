class AgentsController < ApplicationController
  before_action :init_agent, only: [:show, :manage, :command, :raw_log, :edit_config, :update_config, :log_tail]


  def index
    # for demo
    kudu_prepare_table

    @items = Agent.w_not_deleted.order("created_at desc").all
  end

  def log_tail
    limit = (params[:limit] || 10).to_i
    @logs = file_tail(@agent.app_log_path, limit) if @agent
    render json: @logs
  end

  def show

  end

  def new
    
  end

  def manage
    @agent_outputs_is_kudu = Dataenchilada::Agents::Manager.agent_outputs_is_kudu?(@agent)
  end

  def raw_log
    send_data @agent.app_log, type: "application/octet-stream", filename: File.basename(@agent.app_log_path)
  end

  def edit_config

  end

  def update_config
    @res = @agent.update_config(params[:config])
    # result
    respond_to do |format|
      if @res
        @restart = Dataenchilada::Agents::Manager.do_command(@agent, 'restart')
        format.html {
          if @restart
            redirect_to manage_agent_path(@agent), notice: 'Command restart sent'
          else
            flash[:error] = "Command restart not sent"
            render :manage
          end
        }
        format.json { return_json(res) }
      else
        format.html {
          flash[:error] = "Something went wrong"
          render :manage
        }
        format.json { return_json(@res)  }
      end
    end

  end

  def command

    # input
    @cmd = params[:cmd]

    # work
    @res = Dataenchilada::Agents::Manager.do_command(@agent, @cmd)


    # result
    respond_to do |format|
      if @res
        format.html {
          if @cmd == "delete"
            redirect_to agents_path, notice: "agent #{@agent.title} was deleted"
          else
            redirect_to manage_agent_path(@agent), notice: "Command #{@cmd} sent"
          end

        }
        format.json { return_json(@res) }
      else
        format.html {
          flash[:error] = "Something went wrong"
          render :manage
        }
        format.json { return_json(@res)  }
      end
    end

  end


  private

  def init_agent
    agent_id = params[:id]
    @agent = Agent.get_by_id(agent_id)
    if @agent.nil?
      raise 'Agent not set'
    end
  end

  # for demo
  def kudu_prepare_table
    impala_host, impala_port = get_impala_address
    Dataenchilada::Agents::CreateKuduTable.prepare_table_for_demo(impala_host, impala_port, 'bplugin', 'shop_logs')
  end

  def get_impala_address
    sys_prop = Dataenchilada::Agents::Configurator.get_system_props
    impala_host = sys_prop[:impala_host]
    impala_port = sys_prop[:impala_port] || 21000
    return [impala_host, impala_port]
  end

end
