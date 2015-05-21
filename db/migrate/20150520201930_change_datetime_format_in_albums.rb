class ChangeDatetimeFormatInAlbums < ActiveRecord::Migration
  def up
    change_column :albums, :release_date, :string
  end

  def down
    change_column :albums, :release_date, :datetime
  end
end
