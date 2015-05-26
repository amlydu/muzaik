class Song < ActiveRecord::Base
  belongs_to :album
  ratyrate_rateable "speed"
end
