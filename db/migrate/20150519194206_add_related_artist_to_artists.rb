class AddRelatedArtistToArtists < ActiveRecord::Migration
  def change
    add_column :artists, :related_artist, :string
  end
end
