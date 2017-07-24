class Ticket < ApplicationRecord
  belongs_to :event
  validates_presence_of :name, :price

  has_many :registrations

end
