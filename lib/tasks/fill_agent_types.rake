namespace :agent do
  desc "fill_agent_types"
  task :fill_types => :environment do
    AgentType.create!(name: 'fluentd', title: 'fluentd')
    AgentType.create!(name: 'flume', title: 'flume')
  end
end