source "https://rubygems.org"

ruby "2.3.1"

gemspec

gem 'endpoint_base', git: 'https://github.com/Follain/endpoint_base'

group :test do
  gem 'rspec'
  gem 'webmock'
  gem 'rack-test'
end

group :production do
  gem 'foreman'
  gem 'unicorn'
end

group :development do
  gem 'pry'
  gem 'shotgun'
end

group :test, :development do
  gem 'pry-byebug'
end
