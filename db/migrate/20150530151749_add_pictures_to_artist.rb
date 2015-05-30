class AddPicturesToArtist < ActiveRecord::Migration
  def change
    add_column :artists, :picture, :string
  end
end
