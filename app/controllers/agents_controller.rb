class AgentsController < ApplicationController
  before_action :init_agent, only: [:manage, :command]


  def index

    @items = Agent.w_not_deleted.order("created_at desc").all


  end

  def new
    
  end

  def manage


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
          redirect_to manage_agent_path(@agent), notice: 'Command sent'
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


  private

  def init_agent
    agent_id = params[:id]

    @agent = Agent.get_by_id(agent_id)

    if @agent.nil?
      raise 'Agent not set'
    end



  end
end
