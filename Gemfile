source 'https://rubygems.org'

# Specify your gem's dependencies in elasticsearch-model-extensions.gemspec
gemspec path: File.dirname(__FILE__)

group :test do
  gem 'rspec', '~> 3.1.0'
  gem 'database_cleaner'
  gem 'coveralls', require: false
  gem 'parallel'
end

group :test, :development do
  gem 'activerecord', '~> 3.2'
  gem 'sqlite3'
  gem 'elasticsearch-model'
  gem 'elasticsearch-extensions'
  gem 'delayed_job_active_record', '~> 4.0.1'
end
