require 'shellwords'

class WeasyPrint

  class NoExecutableError < StandardError
    def initialize
      msg  = "No weasyprint executable found at #{WeasyPrint.configuration.weasyprint}\n"
      msg << ">> Please install weasyprint - http://weasyprint.org/docs/install/"
      super(msg)
    end
  end

  class ImproperSourceError < StandardError
    def initialize(msg)
      super("Improper Source: #{msg}")
    end
  end

  attr_accessor :source, :stylesheets
  attr_reader :options

  def initialize(url_file_or_html, options = {})
    @source = Source.new(url_file_or_html)

    @stylesheets = []

    @options = WeasyPrint.configuration.default_options.merge(options)
    @options = normalize_options(@options)

    raise NoExecutableError.new unless File.exist?(WeasyPrint.configuration.weasyprint)
  end

  def command(path = nil)
    args = [executable]
    args += @options.to_a.flatten.compact

    if @source.html?
      args << '-' # Get HTML from stdin
    else
      args << @source.to_s
    end

    args << (path || '-') # Write to file or stdout

    args.shelljoin
  end

  def executable
    default = WeasyPrint.configuration.weasyprint
    return default if default !~ /^\// # its not a path, so nothing we can do
    if File.exist?(default)
      default
    else
      default.split('/').last
    end
  end

  def to_pdf(path=nil)
    append_stylesheets

    invoke = command(path)

    result = IO.popen(invoke, "wb+") do |pdf|
      pdf.puts(@source.to_s) if @source.html?
      pdf.close_write
      pdf.gets(nil)
    end
    result = File.read(path) if path

    # $? is thread safe per http://stackoverflow.com/questions/2164887/thread-safe-external-process-in-ruby-plus-checking-exitstatus
    raise "command failed (exitstatus=#{$?.exitstatus}): #{invoke}" if result.to_s.strip.empty? or !successful?($?)
    return result
  end

  def to_file(path)
    self.to_pdf(path)
    File.new(path)
  end

  protected

    REPEATABLE_OPTIONS = %w[]

    def style_tag_for(stylesheet)
      "<style>#{File.read(stylesheet)}</style>"
    end

    def append_stylesheets
      raise ImproperSourceError.new('Stylesheets may only be added to an HTML source') if stylesheets.any? && !@source.html?

      stylesheets.each do |stylesheet|
        if @source.to_s.match(/<\/head>/)
          @source = Source.new(@source.to_s.gsub(/(<\/head>)/) {|s| style_tag_for(stylesheet) + s })
        else
          @source.to_s.insert(0, style_tag_for(stylesheet))
        end
      end
    end

    def normalize_options(options)
      normalized_options = {}

      options.each do |key, value|
        next if !value

        # The actual option for weasyprint
        normalized_key = "--#{normalize_arg key}"

        # If the option is repeatable, attempt to normalize all values
        if REPEATABLE_OPTIONS.include? normalized_key
          normalize_repeatable_value(value) do |normalized_key_piece, normalized_value|
            normalized_options[[normalized_key, normalized_key_piece]] = normalized_value
          end
        else # Otherwise, just normalize it like usual
          normalized_options[normalized_key] = normalize_value(value)
        end
      end

      normalized_options
    end

    def normalize_arg(arg)
      arg.to_s.downcase.gsub(/[^a-z0-9]/,'-')
    end

    def normalize_value(value)
      case value
      when TrueClass, 'true' #ie, ==true, see http://www.ruby-doc.org/core-1.9.3/TrueClass.html
        nil
      when Hash
        value.to_a.flatten.collect{|x| normalize_value(x)}.compact
      when Array
        value.flatten.collect{|x| x.to_s}
      else
        value.to_s
      end
    end

    def normalize_repeatable_value(value)
      case value
      when Hash, Array
        value.each do |(key, value)|
          yield [normalize_value(key), normalize_value(value)]
        end
      else
        [normalize_value(value), '']
      end
    end

    def successful?(status)
      status.success?
    end

end
