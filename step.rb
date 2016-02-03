require 'net/http'
require 'json'
require 'pathname'
require 'fileutils'

ios_license_path = "$HOME/Library/MonoTouch/License.v2"
android_license_path = "$HOME/Library/MonoAndroid/License"
mac_license_path = "$HOME/Library/Xamarin.Mac/License.v2"

build_slug = ENV['build_slug']
get_ios_license = ENV['xamarin_ios_license'].eql?("yes") ? true : false
get_android_license = ENV['xamarin_android_license'].eql?("yes") ? true : false
get_mac_license = ENV['xamarin_mac_license'].eql?("yes") ? true : false

puts "\e[34mGathering Xamarin License requirements"
licenses = []
if get_ios_license && File.exists?(ios_license_path)
  get_ios_license = false
  puts "Skipping Xamarin.iOS license downloading. Already downloaded."
elsif get_ios_license
  licenses << "Xamarin.iOS"
end
if get_android_license && File.exists?(android_license_path)
  android_license_path = false
  puts "Skipping Xamarin.Android license downloading. Already downloaded."
elsif get_android_license
  licenses << "Xamarin.Android"
end
if get_mac_license && File.exists?(mac_license_path)
  mac_license_path = false
  puts "Skipping Xamarin.Mac license downloading. Already downloaded."
elsif get_mac_license
  licenses << "Xamarin.Mac"
end

if licenses.count > 0
  puts "Downloading licenses: #{licenses.join(', ')}"
end

# Get machine information
machine_data = `/Library/Frameworks/Xamarin.iOS.framework/Versions/Current/bin/mtouch --datafile`

url = 'http://xamarin.bitrise.io/add_machine'

uri = URI.parse(url)
http = Net::HTTP.new(uri.host,uri.port)
req = Net::HTTP::Post.new(uri.path)
body = {
  :build_slug => build_slug,
  :device => machine_data,
  :ios_license => get_ios_license,
  :android_license => get_android_license,
  :mac_license => get_mac_license
}.to_json

response = http.request(req, body)
body = JSON.parse(response.body)

if body['success'] == false
  puts "\e[31m#{body['error']}\e[0m"
  exit 1
end

puts ""
puts "\e[32mSuccessfully logged in to Xamarin"

if get_ios_license
  FileUtils.mkdir_p(Pathname.new(ios_license_path).dirname)
  `echo "#{body['ios']}" | base64 --decode > "#{ios_license_path}"`
  puts "  \e[32mXamarin.iOS license file updated\e[0m (usage: #{body['ios_used_machines']}/#{body['ios_allowed_machines']})"
end

if get_android_license
  FileUtils.mkdir_p(Pathname.new(android_license_path).dirname)
  `echo "#{body['android']}" | base64 --decode > "#{android_license_path}"`

  puts "  \e[32mXamarin.Android license file updated\e[0m (usage: #{body['android_used_machines']}/#{body['android_allowed_machines']})"
end

if get_mac_license
  FileUtils.mkdir_p(Pathname.new(mac_license_path).dirname)
  `echo "#{body['mac']}" | base64 --decode > "#{mac_license_path}"`

  puts "  \e[32mXamarin.Mac license file updated\e[0m (usage: #{body['mac_used_machines']}/#{body['mac_allowed_machines']})"
end

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
  puts "\e[31mFailed to update Xamarin Components Credentials\e[0m"
else
  `echo "#{body['credential']}" | base64 --decode > "$HOME/.xamarin-credentials"`
  puts "  \e[32mUpdated Xamarin Components Credentials\e[0m"
end
