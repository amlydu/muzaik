class Artist < ActiveRecord::Base
  has_many :albums
  #songs we're seeing if this is inherited through albums

end
