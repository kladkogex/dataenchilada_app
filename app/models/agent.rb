class Agent < ActiveRecord::Base

  belongs_to :agent_type
  has_one :source
  has_many :outputs
  has_many :syncs

  validates :title, presence: true, uniqueness: true
  validates :tag, presence: false, uniqueness: true


  ### status, state
  include AASM
  include AgentStatus

  scope :w_not_deleted, -> { where('status != ?', statuses[:removed]) }
  #scope :w_active, -> { where('status = ?', STATUS_ACTIVE) }
  #scope :w_active, -> { active }

  # callbacks
  after_create :after_create


  ### get

  def conf_name
    "#{name}_#{id}"
  end

  def self.get_by_id(id)
    where(id: id).first
  end

  def base_dir
    File.join(Rails.root, "data/agents/#{conf_name}")
  end

  def log_prefix
    "/var/log"
  end

  def config_path
    File.join(base_dir, "agent.conf")
  end

  def log_path
    File.join(base_dir, "agent.log")
    #File.join(log_prefix, "data_enchilada_agent_#{conf_name}.out.log")
  end

  def app_log_path
    File.join(log_prefix, "data_enchilada_agent_#{conf_name}.out.log")
  end

  def config
    File.read config_path rescue ''
  end

  def log
    File.read log_path rescue ''
  end

  def update_config content
    File.open(config_path, 'w') do |f|
      f.write(content)
    end
  end

  def after_create
    self.tag = conf_name
    self.save!
  end

end
