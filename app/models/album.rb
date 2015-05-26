class Album < ActiveRecord::Base
  belongs_to :artist
  has_many :songs
  has_many :ratings
  has_many :users, through: :ratings
  accepts_nested_attributes_for :songs
  ratyrate_rateable "speed"

end
