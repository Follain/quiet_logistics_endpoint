Gem::Specification.new do |s|
  s.name  = "quiet_logistics_endpoint"
  s.version = "0.0.1"

  s.summary = "Cangaroo endpoint for Quiet Logistics"
  s.description = ""

  s.authors = ["Joe Lind"]
  s.email = "joe@shopfollain.com"
  s.homepage = "http://shopfollain.com"

  s.files = ([`git ls-files lib/`.split("\n")]).flatten

  s.test_files = `git ls-files spec/`.split("\n")

  s.add_runtime_dependency 'sinatra'
  s.add_runtime_dependency 'tilt'
  s.add_runtime_dependency 'tilt-jbuilder'
  s.add_runtime_dependency 'multi_json'
  s.add_runtime_dependency 'nokogiri'
  s.add_runtime_dependency 'aws-sdk-v1'
end
