class Album < ActiveRecord::Base
  belongs_to :artist
  has_many :songs
  has_many :ratings
  has_many :users, through: :ratings
  accepts_nested_attributes_for :songs

  # def sort_albums
  #   albumArray = []
  #   self.each do |album|
  #     albumArray << album.name
  #     albumArray.sort
  #   end
  # end
end
