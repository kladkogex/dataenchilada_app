class Agent < ActiveRecord::Base
  has_one :source
  has_many :outputs
  has_many :syncs


  ### status, state
  include AASM
  include AgentStatus

  scope :w_not_deleted, -> { where('status != ?', statuses[:removed]) }
  #scope :w_active, -> { where('status = ?', STATUS_ACTIVE) }
  #scope :w_active, -> { active }

  ### get

  def self.get_by_id(id)
    where(id: id).first
  end
end
