class Type < ApplicationRecord
  has_many :alerte
  validates_presence_of :name, presence: true
  validates_uniqueness_of :name
end
