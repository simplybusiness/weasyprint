class WeasyPrint
  class Configuration
    attr_accessor :meta_tag_prefix, :default_options, :root_url
    attr_writer :weasyprint, :verbose

    def initialize
      @verbose         = false
      @meta_tag_prefix = 'weasyprint-'
      @default_options = {
        encoding: 'UTF-8'
      }
    end

    def weasyprint
      @weasyprint ||= (defined?(Bundler::GemfileError) ? `bundle exec which weasyprint` : `which weasyprint`).chomp
    end

    def quiet?
      !@verbose
    end

    def verbose?
      @verbose
    end
  end

  class << self
    attr_accessor :configuration
  end

  # Configure WeasyPrint someplace sensible,
  # like config/initializers/weasyprint.rb
  #
  # @example
  #   WeasyPrint.configure do |config|
  #     config.weasyprint = '/usr/bin/weasyprint'
  #   end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
