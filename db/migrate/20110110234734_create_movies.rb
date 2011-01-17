class CreateMovies < ActiveRecord::Migration
  def self.up
    create_table :movies do |t|
      t.text :title
      t.float :rating
      t.text :path
      t.string :filename
      t.string :checksum
      t.string :imdb_id
      t.text :director
      t.text :genres

      t.timestamps
    end
  end

  def self.down
    drop_table :movies
  end
end
