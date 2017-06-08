require 'net/http'
require 'json'
require 'pathname'
require 'fileutils'

build_slug = ENV['build_slug']

# Get components
puts ""
puts "\e[34mUpdating Xamarin Components Credentials\e[0m"

uri = URI.parse("http://xamarin.bitrise.io/components")
http = Net::HTTP.new(uri.host,uri.port)
req = Net::HTTP::Post.new(uri.path)
body = {
  :build_slug => build_slug
}.to_json

response = http.request(req, body)
body = JSON.parse(response.body)

if body['success'] == false
  puts body
  puts "\e[31mFailed to update Xamarin Components Credentials\e[0m"
  exit 1
else
  `echo "#{body['credential']}" | base64 --decode > "$HOME/.xamarin-credentials"`
  puts "  \e[32mUpdated Xamarin Components Credentials\e[0m"
end
