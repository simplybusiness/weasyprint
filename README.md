# WeasyPrint

> ## ⚠️ This project is archived and no longer maintained
>
> As of August 2026, Simply Business is no longer maintaining this gem. No further
> updates, bug fixes, or security patches will be released, and issues and pull
> requests are no longer being monitored.

---

Create PDFs using plain old HTML+CSS. Uses [weasyprint](http://weasyprint.org/) on the back-end which renders HTML.

## Install

### WeasyPrint
```
gem install weasyprint
```
### weasyprint

1. Install by hand (recommended):

    <http://weasyprint.org/docs/install/>

## Usage
```ruby
# WeasyPrint.new takes the HTML and any options for weasyprint
# run `weasyprint --help` for a full list of options
kit = WeasyPrint.new(html)
kit.stylesheets << '/path/to/css/file'

# Get an inline PDF
pdf = kit.to_pdf

# Save the PDF to a file
file = kit.to_file('/path/to/save/pdf')

# WeasyPrint.new can optionally accept a URL or a File.
# Stylesheets can not be added when source is provided as a URL of File.
kit = WeasyPrint.new('http://google.com')
kit = WeasyPrint.new(File.new('/path/to/html'))

## Configuration
If you're on Windows or you installed weasyprint by hand to a location other than `/usr/local/bin` you will need to tell WeasyPrint where the binary is. You can configure WeasyPrint like so:
```ruby
# config/initializers/weasyprint.rb
WeasyPrint.configure do |config|
  config.weasyprint = '/path/to/weasyprint'
  config.default_options = {
    :resolution => '300',
  }
  # Use only if your external hostname is unavailable on the server.
  config.base_url = "http://localhost"
end
```
## Middleware
WeasyPrint comes with a middleware that allows users to get a PDF view of any page on your site by appending .pdf to the URL.

### Middleware Setup
**Non-Rails Rack apps**
```ruby
# in config.ru
require 'weasyprint'
use WeasyPrint::Middleware
```
**Rails apps**
```ruby
# in application.rb(Rails3) or environment.rb(Rails2)
require 'weasyprint'
config.middleware.use WeasyPrint::Middleware
```
**With WeasyPrint options**
```ruby
# options will be passed to WeasyPrint.new
config.middleware.use WeasyPrint::Middleware, :resolution => '300'
```
**With conditions to limit routes that can be generated in pdf**
```ruby
# conditions can be regexps (either one or an array)
config.middleware.use WeasyPrint::Middleware, {}, :only => %r[^/public]
config.middleware.use WeasyPrint::Middleware, {}, :only => [%r[^/invoice], %r[^/public]]

# conditions can be strings (either one or an array)
config.middleware.use WeasyPrint::Middleware, {}, :only => '/public'
config.middleware.use WeasyPrint::Middleware, {}, :only => ['/invoice', '/public']

# conditions can be regexps (either one or an array)
config.middleware.use WeasyPrint::Middleware, {}, :except => [%r[^/prawn], %r[^/secret]]

# conditions can be strings (either one or an array)
config.middleware.use WeasyPrint::Middleware, {}, :except => ['/secret']
```
**Saving the generated .pdf to disk**

Setting the `WeasyPrint-save-pdf` header will cause WeasyPrint to write the generated .pdf to the file indicated by the value of the header.

For example:
```ruby
headers['WeasyPrint-save-pdf'] = 'path/to/saved.pdf'
```

Will cause the .pdf to be saved to `path/to/saved.pdf` in addition to being sent back to the client.  If the path is not writable/non-existant the write will fail silently.  The `WeasyPrint-save-pdf` header is never sent back to the client.

## Troubleshooting

*  **Single thread issue:** In development environments it is common to run a
   single server process. This can cause issues when rendering your pdf
   requires weasyprint to hit your server again (for images, js, css).
   This is because the resource requests will get blocked by the initial
   request and the initial request will be waiting on the resource
   requests causing a deadlock.

   This is usually not an issue in a production environment. To get
   around this issue you may want to run a server with multiple workers
   like Passenger or try to embed your resources within your HTML to
   avoid extra HTTP requests.
   
   Example solution (rails / bundler), add unicorn to the development 
   group in your Gemfile `gem 'unicorn'` then run `bundle`. Next, add a 
   file `config/unicorn.conf` with
   
        worker_processes 3
   
   Then to run the app `unicorn_rails -c config/unicorn.conf` (from rails_root)

## Note on Patches/Pull Requests

* Fork the project.
* Setup your development environment with: `gem install bundler`; `bundle install`
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself so we can ignore when we pull)
* Send a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 Jared Pace. See LICENSE for details. Additional work Copyright (c) 2014 Simply Business
