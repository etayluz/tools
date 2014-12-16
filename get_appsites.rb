require 'nokogiri'
require 'open-uri'
require "csv"
require 'uri'

CSV.foreach("./apps.csv", headers: true) do |row|
  puts row[1]
  doc = Nokogiri::HTML(open(row[1]))
  array = doc.css('div.app-links a').map { |link| link['href'] }
  array.uniq!
  array.each { |url| 
  	# puts url 
  	  url = "http://#{url}" if URI.parse(url).scheme.nil?
	  host = URI.parse(url).host.downcase
	  test = host.start_with?('www.') ? host[4..-1] : host
	  puts test
  }
  puts
end

# csv_text = File.read('...')

# CSV.open("./apps.csv", "r") do |csv|
#   h.each do |key, value|
#       csv << [key, value]
#   end
# end

def get_host_without_www(url)
  url = "http://#{url}" if URI.parse(url).scheme.nil?
  host = URI.parse(url).host.downcase
  host.start_with?('www.') ? host[4..-1] : host
end