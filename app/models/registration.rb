class Registration < ApplicationRecord

  STATUS = ["pending", "confirmed"]
  validates_inclusion_of :status, :in => STATUS
  validates_presence_of :status, :ticket_id

  belongs_to :event
  belongs_to :ticket
  belongs_to :user, :optional => true

  scope :by_status, ->(s){ where( :status => s ) }
  scope :by_ticket, ->(t){ where( :ticket_id => t) }

  attr_accessor :current_step
  validates_presence_of :name, :email, :cellphone, :if => :should_validate_basic_data?
  validates_presence_of :name, :email, :cellphone, :bio, :if => :should_validate_all_data?

  validate :check_event_status, :on => :create

  before_validation :generate_uuid, :on => :create

  has_paper_trail

  def to_param
    self.uuid
  end

  protected

  def should_validate_basic_data?
    current_step == 2 # only validates on step2
  end

  def should_validate_all_data?
    current_step == 3 || status == "confirmed" # validates on step, or confirmed status
  end

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end

  def check_event_status
      if self.event.status == "draft"
        errors.add(:base, "活动尚未开放报名")
      end
    end


end
