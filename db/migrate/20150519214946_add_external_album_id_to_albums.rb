class AddExternalAlbumIdToAlbums < ActiveRecord::Migration
  def change
    add_column :albums, :external_album_id, :string
  end
end
