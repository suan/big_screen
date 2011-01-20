# require 'mime/types'

class String
  def oink
    puts "OOOOOOIIIIIIIINNNNNNNKKKKKKKK"
  end

  # count as a movie if is of type video and larger than 300MB
  def is_movie?
    return false unless File.file? self and File.size(self) > 314572800
    mts = MIME::Types.of(self)
    return true if not mts.empty? and mts.first.media_type == 'video'
    Rails.logger.warn "WARNING: #{self} may be a movie but its mime type is unrecognized!" if mts.empty?
    return false
  end
  
  def has_another_movie(except_movie)
    Dir.foreach(self) {|fn|
      fn = File.join(self, fn)
      return true if fn.is_movie? and fn != except_movie
    }
    false
  end
  
  def is_year?
    return false if self.length != 4
    num = self.to_i
    num != 0 && num < 2100
  end
  
  def is_legible?
    return true if length < 2
    (self =~ /^[A-Z0-9]?[a-z]+$/ or self =~ /^[0-9]+$/) ? true : false
  end
  
  def is_suspect?
    self.scan(/[[:upper:]]/).length > 1 or self =~ /[[:alpha:]][[:digit:]]/) and
      not self.is_roman_numeral?
  end
  
  def is_roman_numeral?
    self =~ /^(I|V)+$/
  end
  
  def clean_cut(pos)
    # puts "called clean_cut(#{pos})"
    begin
      pos -= 1
    end while self[pos, 1] !~ /[[:alnum:]]/
    # until self[pos, 1] =~ /[[:alnum:]]/ do
      # pos -= 1
    # end
    # puts "clean_cut returning #{self[0..pos]}"
    self[0..pos]
  end
  
  def to_windows
    "\"#{self.gsub('/', '\\\\')}\""
  end
end
