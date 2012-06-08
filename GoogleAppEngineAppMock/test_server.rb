require "net/https"
require "uri"

uri = URI.parse("https://quantumagiletoolbox-dev.appspot.com/ready")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
# http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Get.new(uri.request_uri)

response = http.request(request)

if response.is_a?(Net::HTTPOK)
  puts "Very nice"
else
  puts "Very bad"
end

puts response.body
puts response.code
# response["header-here"] # All headers are lowercase
