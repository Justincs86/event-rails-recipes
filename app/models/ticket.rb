class Ticket < ApplicationRecord
  belongs_to :event, :optional => true
  validates_presence_of :name, :price

  has_many :registrations

end
