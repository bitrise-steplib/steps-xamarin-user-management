require 'net/http'
require 'json'
require 'base64'
require 'pathname'
require 'fileutils'

repository = ENV['bitrise_repository']
action = ENV['xamarin_action']
get_ios_license = ENV['xamarin_ios_license'].eql?("yes") ? true : false
get_android_license = ENV['xamarin_android_license'].eql?("yes") ? true : false

# Get machine information
machine_data = `/Library/Frameworks/Xamarin.iOS.framework/Versions/Current/bin/mtouch --datafile`

# Get URL for action
url = nil
case action
when "login"
  url = 'http://xamarin.bitrise.io/activate'
when "logout"
  url = 'http://xamarin.bitrise.io/deactivate'
else
  puts "\e[31mUndefined action found\e[0m"
  exit 1
end

unless url
  puts "\e[31mNo user management URL found\e[0m"
  exit 1
end

uri = URI.parse(url)
http = Net::HTTP.new(uri.host,uri.port)
req = Net::HTTP::Post.new(uri.path)
body = {
  :slug => repository,
  :device => machine_data,
  :ios_license => get_ios_license,
  :android_license => get_android_license
}.to_json

response = http.request(req, body)
body = JSON.parse(response.body)

if body['success'] == false
  puts "\e[31m#{body['error']}\e[0m"

  if action.eql? "logout"
    puts "To manually remove your Xamarin license associated with this machine go to https://store.xamarin.com/account/my/subscription/computers"
  end
  exit 1
end

case action
when "login"
  if body['allowedMachines'] != 0 && body['usedMachines'] != 0
    puts "Machine usage: #{body['usedMachines']}/#{body['allowedMachines']}"
  end

  if get_ios_license
    ios_license_path = "$HOME/Library/MonoTouch/License.v2"
    ios_license = Base64.strict_decode64(body['ios'])

    if File.exists?(ios_license_path)
      puts "\e[31mFailed to update iOS license. License already exists at path\e[0m"
      exit 1
    else
      FileUtils.mkdir_p(Pathname.new(ios_license_path).dirname)
      File.open(ios_license_path, 'w') { |file| file.write(ios_license) }
      puts "Xamarin.iOS license file updated"
    end
  end

  if get_android_license
    android_license_path = "$HOME/Library/MonoAndroid/License.v2"
    android_license = Base64.strict_decode64(body['android'])

    if File.exists?(android_license_path)
      puts "\e[31mFailed to update Android license. License already exists at path\e[0m"
      exit 1
    else
      FileUtils.mkdir_p(Pathname.new(android_license_path).dirname)
      File.open(android_license_path, 'w') { |file| file.write(android_license) }
      puts "Xamarin.Android license file updated"
    end
  end

  puts ""
  puts "\e[32mSuccessfully logged in to Xamarin"
when "logout"
  puts ""
  puts "\e[32mSuccessfully logged out from Xamarin"
end
