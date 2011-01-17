module MoviesHelper
  def alt_gen
    @alt = 'alt' if @alt.nil?
    return (@alt = @alt.blank? ? 'alt' : '')
  end
end
