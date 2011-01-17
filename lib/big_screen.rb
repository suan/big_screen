class BigScreen
  def self.config_file
    @config_file ||= YAML.load_file config_file_path
  end

  def self.config_file_path
    if RAILS_ENV == 'production'
        "#{RAILS_ROOT}/config/config_production.yml"
      else
        "#{RAILS_ROOT}/config/config_development.yml"
      end
  end
end