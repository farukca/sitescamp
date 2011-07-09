source 'http://rubygems.org'

gem 'rails', '3.0.1'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'
gem 'sqlite3-ruby', :require => 'sqlite3'
# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end

gem 'mongoid', '~> 2.0'
gem 'bson_ext', '~> 1.3'
gem 'mongoid_taggable'

gem 'haml'
#gem 'compass', '>= 0.10.6'

gem 'formtastic'
gem 'client_side_validations'
gem 'kaminari'

gem 'ruby-readability', :require => 'readability'
gem 'sem_extractor', :git => 'git://github.com/apneadiving/SemExtractor.git'
gem 'auto_excerpt'
gem 'summarize'

#authentication
gem 'devise', '1.1.5'
gem 'omniauth'

#File uploading
gem 'carrierwave'
gem 'mini_magick'

group :test, :development do
  gem 'jquery-rails'
  gem 'factory_girl_rails'
  gem 'ruby-debug19' if RUBY_VERSION.include? "1.9"
  gem 'ruby-debug' if RUBY_VERSION.include? "1.8"
  gem 'launchy'
  gem 'rspec'
  gem 'webrat'
  #gem 'mongrel', :require => false if RUBY_VERSION.include? "1.8"
  gem 'mongrel', '>= 1.2.0.pre2'
end

#background process
gem 'delayed_job'
gem 'delayed_job_mongoid'
gem 'whenever', :require => false

#rss feed
gem 'nokogiri', '1.4.4'
group :after_initialize do
  gem "feedzirra", :git => "git://github.com/pauldix/feedzirra.git"
end
