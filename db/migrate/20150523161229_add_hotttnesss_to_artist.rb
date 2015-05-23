class AddHotttnesssToArtist < ActiveRecord::Migration
  def change
    add_column :artists, :hotttnesss, :float
  end
end
