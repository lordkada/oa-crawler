source 'http://rubygems.org'

gem 'rails', '~> 3.1.0'

gem 'jruby-openssl'
gem 'json'
gem 'twitter'

gem "neo4j", "~> 1.3.1"
gem 'oa_model', :path => '../oa-model'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :development do
  gem 'rspec-rails'
  gem 'activerecord-jdbcsqlite3-adapter'
end

group :production do
  gem 'activerecord-jdbcpostgresql-adapter'
end

group :test do
  gem 'activerecord-jdbcsqlite3-adapter'
  gem 'rspec-rails'
end
