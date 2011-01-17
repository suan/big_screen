class Movie < ActiveRecord::Base
  attr_accessor :raw_title, :guessed_title
  
  def is_new?
    id.nil?
  end
  
  def full_path
    File.join(path, filename).encode('Windows-1252')
    # File.join(path, filename).encode('utf-8')
  end
end
