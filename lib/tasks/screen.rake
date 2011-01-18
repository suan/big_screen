# encoding: utf-8

desc "Process movie files and store their associated info in the db, then Delete movies in the database that no longer exist on the filesystem"
task(:screen => :environment) do
  Rake::Task['batch_parse'].execute
  Rake::Task['clean_up'].execute
end