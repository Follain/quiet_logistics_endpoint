# frozen_string_literal: true
source 'https://rubygems.org'

ruby '2.3.3'

gemspec

gem 'endpoint_base', git: 'https://github.com/Follain/endpoint_base'

group :test do
  gem 'rack-test'
  gem 'rspec'
  gem 'webmock'
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
  gem 'pronto-rubocop'
  gem 'pry-byebug'
end
