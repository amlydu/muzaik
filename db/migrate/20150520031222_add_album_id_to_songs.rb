class AddAlbumIdToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :album_id, :integer
    add_index :songs, :album_id
  end
end
