#encoding: UTF-8
require 'spec_helper'

describe WeasyPrint do

  context "initialization" do
    it "should accept HTML as the source" do
      weasyprint = WeasyPrint.new('<h1>Oh Hai</h1>')
      expect(weasyprint.source).to be_html
      expect(weasyprint.source.to_s).to eq('<h1>Oh Hai</h1>')
    end

    it "should accept a URL as the source" do
      weasyprint = WeasyPrint.new('http://google.com')
      expect(weasyprint.source).to be_url
      expect(weasyprint.source.to_s).to eq('http://google.com')
    end

    it "should accept a File as the source" do
      file_path = File.join(SPEC_ROOT,'fixtures','example.html')
      weasyprint = WeasyPrint.new(File.new(file_path))
      expect(weasyprint.source).to be_file
      expect(weasyprint.source.to_s).to eq(file_path)
    end

    it "should parse the options into a cmd line friedly format" do
      weasyprint = WeasyPrint.new('html', :resolution => '300')
      expect(weasyprint.options).to have_key('--resolution')
    end

    it "should parse complex options into a cmd line friedly format" do
      weasyprint = WeasyPrint.new('html', :replace => {'value' => 'something else'} )
      expect(weasyprint.options).to have_key('--replace')
    end

    it "should provide default options" do
      weasyprint = WeasyPrint.new('<h1>Oh Hai</h1>')
      ['--format'].each do |option|
        expect(weasyprint.options).to have_key(option)
      end
    end

    it "should default to 'UTF-8' encoding" do
      weasyprint = WeasyPrint.new('Captación')
      expect(weasyprint.options['--encoding']).to eq('UTF-8')
    end

    it "should not have any stylesheedt by default" do
      weasyprint = WeasyPrint.new('<h1>Oh Hai</h1>')
      expect(weasyprint.stylesheets).to be_empty
    end
  end

  context "command" do
    # it "should contstruct the correct command" do
    #   weasyprint = WeasyPrint.new('html', :page_size => 'Letter', :toc_l1_font_size => 12, :replace => {'foo' => 'bar'})
    #   command = weasyprint.command
    #   expect(command).to include "wkhtmltopdf"
    #   expect(command).to include "--page-size Letter"
    #   expect(command).to include "--toc-l1-font-size 12"
    #   expect(command).to include "--replace foo bar"
    # end

    # it "should setup one cookie only" do
    #   weasyprint = WeasyPrint.new('html', cookie: {cookie_name: :cookie_value})
    #   command = weasyprint.command
    #   expect(command).to include "--cookie cookie_name cookie_value"
    # end

    # it "should setup multiple cookies when passed a hash" do
    #   weasyprint = WeasyPrint.new('html', :cookie => {:cookie_name1 => :cookie_val1, :cookie_name2 => :cookie_val2})
    #   command = weasyprint.command
    #   expect(command).to include "--cookie cookie_name1 cookie_val1"
    #   expect(command).to include "--cookie cookie_name2 cookie_val2"
    # end

    # it "should setup multiple cookies when passed an array of tuples" do
    #   weasyprint = WeasyPrint.new('html', :cookie => [[:cookie_name1, :cookie_val1], [:cookie_name2, :cookie_val2]])
    #   command = weasyprint.command
    #   expect(command).to include "--cookie cookie_name1 cookie_val1"
    #   expect(command).to include "--cookie cookie_name2 cookie_val2"
    # end

    # it "will not include default options it is told to omit" do
    #   WeasyPrint.configure do |config|
    #     config.default_options[:disable_smart_shrinking] = true
    #   end

    #   weasyprint = WeasyPrint.new('html')
    #   expect(weasyprint.command).to include('--disable-smart-shrinking')
    #   weasyprint = WeasyPrint.new('html', :disable_smart_shrinking => false)
    #   expect(weasyprint.command).not_to include('--disable-smart-shrinking')
    # end

    it "should encapsulate string arguments in quotes" do
      weasyprint = WeasyPrint.new('html', :header_center => "foo [page]")
      expect(weasyprint.command).to include "--header-center foo\\ \\[page\\]"
    end

    it "should sanitize string arguments" do
      weasyprint = WeasyPrint.new('html', :header_center => "$(ls)")
      expect(weasyprint.command).to include "--header-center \\$\\(ls\\)"
    end

    it "read the source from stdin if it is html" do
      weasyprint = WeasyPrint.new('html')
      expect(weasyprint.command).to match /- -$/
    end

    it "specify the URL to the source if it is a url" do
      weasyprint = WeasyPrint.new('http://google.com')
      expect(weasyprint.command).to match /http:\/\/google.com -$/
    end

    it "should specify the path to the source if it is a file" do
      file_path = File.join(SPEC_ROOT,'fixtures','example.html')
      weasyprint = WeasyPrint.new(File.new(file_path))
      expect(weasyprint.command).to match /#{file_path} -$/
    end

    it "should specify the path for the ouput if a path is given" do
      file_path = "/path/to/output.pdf"
      weasyprint = WeasyPrint.new("html")
      expect(weasyprint.command(file_path)).to match /#{file_path}$/
    end

    # it "should detect special weasyprint meta tags" do
    #   body = %{
    #     <html>
    #       <head>
    #         <meta name="weasyprint-page_size" content="Legal"/>
    #         <meta name="weasyprint-orientation" content="Landscape"/>
    #       </head>
    #     </html>
    #   }
    #   weasyprint = WeasyPrint.new(body)
    #   command = weasyprint.command
    #   expect(command).to include "--page-size Legal"
    #   expect(command).to include "--orientation Landscape"
    # end

    # it "should detect cookies meta tag" do
    #   body = %{
    #     <html>
    #       <head>
    #         <meta name="weasyprint-cookie rails_session" content='rails_session_value' />
    #         <meta name="weasyprint-cookie cookie_variable" content='cookie_variable_value' />
    #       </head>
    #     </html>
    #   }
    #   weasyprint = WeasyPrint.new(body)
    #   command = weasyprint.command
    #   expect(command).to include "--cookie rails_session rails_session_value --cookie cookie_variable cookie_variable_value"
    # end

    # it "should detect disable_smart_shrinking meta tag" do
    #   body = %{
    #     <html>
    #       <head>
    #         <meta name="weasyprint-disable_smart_shrinking" content="true"/>
    #       </head>
    #     </html>
    #   }
    #   weasyprint = WeasyPrint.new(body)
    #   command = weasyprint.command
    #   expect(command).to include "--disable-smart-shrinking"
    #   expect(command).not_to include "--disable-smart-shrinking true"
    # end

    # it "should detect names with hyphens instead of underscores" do
    #   body = %{
    #     <html>
    #       <head>
    #         <meta content='Portrait' name='weasyprint-orientation'/>
    #         <meta content="10mm" name="weasyprint-margin-bottom"/>
    #       </head>
    #       <br>
    #     </html>
    #   }
    #   weasyprint = WeasyPrint.new(body)
    #   expect(weasyprint.command).not_to include 'name\='
    # end

    # it "should detect special weasyprint meta tags despite bad markup" do
    #   body = %{
    #     <html>
    #       <head>
    #         <meta name="weasyprint-page_size" content="Legal"/>
    #         <meta name="weasyprint-orientation" content="Landscape"/>
    #       </head>
    #       <br>
    #     </html>
    #   }
    #   weasyprint = WeasyPrint.new(body)
    #   command = weasyprint.command
    #   expect(command).to include "--page-size Legal"
    #   expect(command).to include "--orientation Landscape"
    # end

    # it "should skip non-weasyprint meta tags" do
    #   body = %{
    #     <html>
    #       <head>
    #         <meta name="test-page_size" content="Legal"/>
    #         <meta name="weasyprint-orientation" content="Landscape"/>
    #       </head>
    #       <br>
    #     </html>
    #   }
    #   weasyprint = WeasyPrint.new(body)
    #   command = weasyprint.command
    #   expect(command).not_to include "--page-size Legal"
    #   expect(command).to include "--orientation Landscape"
    # end

    # it "should not use quiet" do
    #   weasyprint = WeasyPrint.new('html', quiet: false)
    #   expect(weasyprint.command).not_to include '--quiet'
    # end

    # it "should use quiet option by defautl" do
    #   weasyprint = WeasyPrint.new('html')
    #   expect(weasyprint.command).to include '--quiet'
    # end

    # it "should not use quiet option in verbose mode" do
    #   WeasyPrint.configure do |config|
    #     config.verbose = true
    #   end

    #   weasyprint = WeasyPrint.new('html')
    #   expect(weasyprint.command).not_to include '--quiet'

    #   WeasyPrint.configure do |config|
    #     config.verbose = false
    #   end
    # end

  end

  context "#to_pdf" do
    it "should generate a PDF of the HTML" do
      weasyprint = WeasyPrint.new('html')
      pdf = weasyprint.to_pdf
      expect(pdf[0...4]).to eq("%PDF") # PDF Signature at beginning of file
    end

    it "should have the stylesheet added to the head if it has one" do
      weasyprint = WeasyPrint.new("<html><head></head><body>Hai!</body></html>")
      css = File.join(SPEC_ROOT,'fixtures','example.css')
      weasyprint.stylesheets << css
      weasyprint.to_pdf
      expect(weasyprint.source.to_s).to include("<style>#{File.read(css)}</style>")
    end

    it "should prepend style tags if the HTML doesn't have a head tag" do
      weasyprint = WeasyPrint.new("<html><body>Hai!</body></html>")
      css = File.join(SPEC_ROOT,'fixtures','example.css')
      weasyprint.stylesheets << css
      weasyprint.to_pdf
      expect(weasyprint.source.to_s).to include("<style>#{File.read(css)}</style><html>")
    end

    it "should throw an error if the source is not html and stylesheets have been added" do
      weasyprint = WeasyPrint.new('http://google.com')
      css = File.join(SPEC_ROOT,'fixtures','example.css')
      weasyprint.stylesheets << css
      expect { weasyprint.to_pdf }.to raise_error(WeasyPrint::ImproperSourceError)
    end

    it "should be able to deal with ActiveSupport::SafeBuffer" do
      weasyprint = WeasyPrint.new(ActiveSupport::SafeBuffer.new "<html><head></head><body>Hai!</body></html>")
      css = File.join(SPEC_ROOT,'fixtures','example.css')
      weasyprint.stylesheets << css
      weasyprint.to_pdf
      expect(weasyprint.source.to_s).to include("<style>#{File.read(css)}</style></head>")
    end

    it "should escape \\X in stylesheets" do
      weasyprint = WeasyPrint.new("<html><head></head><body>Hai!</body></html>")
      css = File.join(SPEC_ROOT,'fixtures','example_with_hex_symbol.css')
      weasyprint.stylesheets << css
      weasyprint.to_pdf
      expect(weasyprint.source.to_s).to include("<style>#{File.read(css)}</style></head>")
    end

    it "should throw an error if it is unable to connect" do
      weasyprint = WeasyPrint.new("http://google.com/this-should-not-be-found/404.html")
      expect { weasyprint.to_pdf }.to raise_error /exitstatus=1/
    end

    it "should generate PDF if there are missing assets" do
      weasyprint = WeasyPrint.new("<html><body><img alt='' src='http://example.com/surely-it-doesnt-exist.gif' /></body></html>")
      pdf = weasyprint.to_pdf
      expect(pdf[0...4]).to eq("%PDF") # PDF Signature at the beginning
    end
  end

  context "#to_file" do
    before do
      @file_path = File.join(SPEC_ROOT,'fixtures','test.pdf')
      File.delete(@file_path) if File.exist?(@file_path)
    end

    after do
      File.delete(@file_path)
    end

    it "should create a file with the PDF as content" do
      weasyprint = WeasyPrint.new('html')
      file = weasyprint.to_file(@file_path)
      expect(file).to be_instance_of(File)
      expect(File.read(file.path)[0...4]).to eq("%PDF") # PDF Signature at beginning of file
    end

    it "should not truncate data (in Ruby 1.8.6)" do
      file_path = File.join(SPEC_ROOT,'fixtures','example.html')
      weasyprint = WeasyPrint.new(File.new(file_path))
      pdf_data = weasyprint.to_pdf
      file = weasyprint.to_file(@file_path)
      file_data = open(@file_path, 'rb') {|io| io.read }
      expect(pdf_data.size).to eq(file_data.size)
    end
  end

  context "security" do
    before do
      @test_path = File.join(SPEC_ROOT,'fixtures','security-oops')
      File.delete(@test_path) if File.exist?(@test_path)
    end

    after do
      File.delete(@test_path) if File.exist?(@test_path)
    end

    it "should not allow shell injection in options" do
      weasyprint = WeasyPrint.new('html', :encoding => "a title\"; touch #{@test_path} #")
      weasyprint.to_pdf
      expect(File.exist?(@test_path)).to be false
    end
  end
end
