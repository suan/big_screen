# encoding: utf-8

desc "Delete movies in the database that no longer exist on the filesystem"
task(:clean_up => :environment) do
  Movie.all.each{ |movie|
    movie.destroy if not File.exists? movie.full_path
  }
end