class AddProducerAndFeaturedArtistToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :producer, :string
    add_column :songs, :featured_artist, :string
  end
end
