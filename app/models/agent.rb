class Agent < ActiveRecord::Base
  belongs_to :agent_type
  has_one :source
  has_many :outputs
  has_many :syncs

  validates :title, presence: true, uniqueness: true
  validates :tag, presence: true, uniqueness: true


  ### status, state
  include AASM
  include AgentStatus

  scope :w_not_deleted, -> { where('status != ?', statuses[:removed]) }
  #scope :w_active, -> { where('status = ?', STATUS_ACTIVE) }
  #scope :w_active, -> { active }

  ### get

  def conf_name
    "#{name}_#{id}"
  end

  def self.get_by_id(id)
    where(id: id).first
  end
end
