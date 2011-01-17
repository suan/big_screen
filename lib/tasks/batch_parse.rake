# encoding: utf-8

desc "Process movie files and store their associated info in the db"
task(:batch_parse => :environment) do
  
  
  
  
  # require(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))
# require "C:/Users/suan/Projects/big_screen/config/environment"
# require 'config/environment'
require 'imdb_party'
require 'digest/md5'
require 'yaml'
require 'find'

require 'string_extensions'
# class String
  # # count as a movie if is of type video and larger than 300MB
  # def is_movie?
    # File.file? self and
      # File.size(self) > 314572800 and
      # MIME::Types.of(self).first.media_type == 'video'
  # end
# end
  
class Token < String
  attr_accessor :pos
  
  def initialize(str, _pos)
    super str
    @pos = _pos
  end
  
  def is_separator?(tokens, index)
    # puts "in is_sep? #{self}, #{pos}"
    (is_year? and
      ((index < tokens.length-1 and not tokens[index+1..-1].any?{|t| t.is_year?}) or
      index == tokens.length-1)) or
    (is_suspect? and index > 0 and tokens[0..index-1].all?{|t| t.is_legible?})
  end
  
  def is_unwanted_year?(tokens)
    is_year? and
      ((pos < tokens.length-1 and not tokens[pos+1..-1].any?{|t| t.is_year?}) or
      pos == tokens.length-1)
  end
end

def movie_dirs
  # use rails' utf-8 handling
  # @movie_dirs ||= config_file['movie_dirs'].map{|str| str.chars}
  @movie_dirs ||= BigScreen.config_file['movie_dirs']
end

# returns the movie object if it exists, otherwise returns file's md5sum
def get_movie(fullpath, use_parent = false)
  puts "in get movie"
  puts "in if config"
  fn = File.basename(fullpath)
  puts "filename: #{fn}"
  dir = File.dirname(fullpath)
  movie = Movie.find_by_filename(fn)
  if movie.nil?
    md5sum = Digest::MD5.file(fullpath).to_s
    puts "md5sum = #{md5sum}"
    movie = Movie.find_by_checksum(md5sum) || Movie.new(:checksum => md5sum)
  else
    puts "found non-new movie!"
  end
  puts "movie is: #{movie.inspect}"
  # movie.path = dir
  movie.path = dir.encode('utf-8')
  # movie.filename = fn
  movie.filename = fn.encode('utf-8')
  movie.raw_title = use_parent ? File.basename(dir) : fn
  return movie
end

def turn_off_refresh
  text = File.read(BigScreen.config_file_path)
  File.open(BigScreen.config_file_path, 'w') { |file|
    file.puts text.gsub(/refresh_all: true/, 'refresh_all: false')
  }
end

def screen_it!(movie)
  print "Guessing title for #{movie.full_path}.. "
  parse_title(movie.raw_title, movie)
  puts "Guessed: #{movie.guessed_title}"
  # imdb stuff...
  imdb = ImdbParty::Imdb.new
  print "Searching imdb for #{movie.guessed_title}.. "
  results = imdb.find_by_title(movie.guessed_title)
  if results.empty?
    puts "Didn't find any matches - using guessed title."
    movie.title = movie.guessed_title
  else
    result = results.first
    puts "Found: #{result[:title]}"
    movie.title = result[:title]
    movie.imdb_id = result[:imdb_id]
    imdb_movie = imdb.find_movie_by_id(result[:imdb_id])
    movie.rating = imdb_movie.rating
    movie.genres = imdb_movie.genres.join(', ')
  end
end

def alnum_split(str)
  puts "splitting #{str}..."
  words = []
  word = ''
  i = 0
  pos = 0
  str.each_char{ |c|
    # puts "c is '#{c}', i is #{i}"
    if c =~ /[[:alnum:]]/ or
    ((c == '?' or c == "'" or c == ',') and word.last =~ /[[:alnum:]]/)
      # puts "in if"
      pos = i if word.blank?
      word << c
    elsif not word.blank?
      # puts "in elsif"
      words << Token.new(word, pos)
      word = ''
    end
    i += 1
  }
  words << Token.new(word, pos) if not word.blank?
  words
end

def parse_title(str, movie)
  puts "strlen: #{str.length}"
  # strip extension
  str.chomp!(File.extname(str)) if movie.raw_title == movie.filename
  # strip non-alphanums from end of string
  until str[-1, 1] =~ /[[:alnum:]]/ do
    str[-1] = ''
  end
  str.gsub!(/_/, ' ')
  str.gsub!(/\./, ' ')
  puts "before alnum_split: #{str}"
  tokens = alnum_split(str)
  
  puts "tokens: #{tokens.inspect}"
  tokens.each_with_index{|t, index|
    if t.is_separator? tokens, index
      movie.guessed_title = str.clean_cut t.pos
      return
    end
  }
  movie.guessed_title = str
  # if a[-4, -1].is_year?
  # else
  # end
end

class File
  ALT_SEPARATOR = '\\\\'
  end

def main
  # config_file['refresh_all']
  # config_file['refresh_once_only']
  # Encoding.default_internal = 'utf-8'
  # Encoding.default_external = 'utf-16le'
  
  # mime-types doesn't know about mkv...
  MIME::Types.add(MIME::Type.from_array("video/x-matroska", ['mkv']))
  MIME::Types.add(MIME::Type.from_array("video/x-m4v", ['m4v']))
  
  movie_dirs.each do |movie_dir|
    # puts movie_dir.inspect
    # puts "movie_dir is a string!" if movie_dir.class == String
    Find.find(movie_dir) do |fn|
      # fn = fn.chars
      puts "#{fn}: #{fn.encoding}"
      # puts "fn is a string!" if fn.class == String
      # fn.force_encoding('utf-8')
      if fn.is_movie?
        parent_dir = File.dirname(fn)
        movie = nil
        if movie_dirs.include? parent_dir or parent_dir.has_another_movie(fn)
          puts fn
          # fn.each_byte{|c| puts c}
          movie = get_movie fn
        else
          puts parent_dir
          movie = get_movie(fn, true)
          puts 'got movie'
        end
        # screen_it!(movie) if movie.is_new? or config_file['refresh_all']
        begin
          # raise Exception.new('fake exception')
          screen_it!(movie)
        rescue Exception => e
          puts "ERROR: screen_it! for #{movie.inspect} FAILED. Reason: #{e.message}
#{e.backtrace.join("\n")}"
          Rails.logger.error "ERROR: screen_it! for #{movie} FAILED. Reason: #{e.message}
#{e.backtrace.join("\n")}"
          next
        end if movie.is_new? or BigScreen.config_file['refresh_all']
        puts movie.filename
        movie.filename.encode!('utf-8')
        puts movie.filename
        movie.path.encode!('utf-8')
        if not movie.save
          puts "Could not save movie #{movie.inspect}: #{movie.errors.full_messages.join(', ')}"
        end
      end
    end
  end
  
  turn_off_refresh if BigScreen.config_file['refresh_all'] and
    BigScreen.config_file['refresh_once_only']
end

# def main
  # # config_file['refresh_all']
  # # config_file['refresh_once_only']
  # Encoding.default_internal = 'utf-8'
  # Encoding.default_external = 'utf-16le'
  
  # movie_dirs.each do |movie_dir|
    # p movie_dir
    # puts "movie_dir is a string!" if movie_dir.class == String
    # Dir.foreach(movie_dir, {:encoding => 'utf-8'}) do |n|
      # # fn = fn.chars
      # # puts "#{fn}: #{fn.encoding}"
      # # puts "fn is a string!" if fn.class == String
      # # fn.force_encoding('utf-8')
      # if File.directory? n
        
      # elsif fn.is_movie?
        # parent_dir = File.dirname(fn)
        # movie = nil
        # if movie_dirs.include? parent_dir or parent_dir.has_another_movie(fn)
          # puts fn
          # # fn.each_byte{|c| puts c}
          # movie = get_movie fn
        # else
          # puts parent_dir
          # movie = get_movie(fn, true)
          # puts 'got movie'
        # end
        # screen_it!(movie) if movie.is_new? or config_file['refresh_all']
        # puts movie.filename
        # movie.filename.encode!('utf-8')
        # puts movie.filename
        # movie.path.encode!('utf-8')
        # if not movie.save
          # puts "Could not save movie #{movie.inspect}: #{movie.errors.full_messages.join(', ')}"
        # end
      # end
    # end
  # end
  
  # turn_off_refresh if config_file['refresh_all'] and config_file['refresh_once_only']
# end

def safe_recurse(dir)
  Dir.foreach(dir, {:encoding => 'utf-8'}) do |n|
    next if n == '.' or n == '..'
    if File.directory? n
      safe_recurse(n)
    else
      n
    end
  end
end

def test
  movie = nil
  5.times do
    movie = nil
    movie = Movie.new
    if not movie.save
      puts "couldnt save"
    end
  end
end

main()
# test()
  
  
  
  
end