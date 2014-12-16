require 'nokogiri'
require 'open-uri'
require "csv"
require 'uri'
require 'domainatrix'

CSV.foreach("./apps.csv", headers: true) do |row|
  puts row[1]
  doc = Nokogiri::HTML(open(row[1]))


  array = doc.css('div.app-links a').map { |link| 

  	url = link['href'] 
  	#   url = "http://#{url}" if URI.parse(url).scheme.nil?
	  # host = URI.parse(url).host.downcase
	  # url = host.start_with?('www.') ? host[4..-1] : host
	url = Domainatrix.parse(url)
	url.domain + "." + url.public_suffix


  }
  array.uniq!
  array.each { |url| 
  	# puts url 
  	#   url = "http://#{url}" if URI.parse(url).scheme.nil?
	  # host = URI.parse(url).host.downcase
	  # test = host.start_with?('www.') ? host[4..-1] : host
	  puts url
  }
  # puts
end

# csv_text = File.read('...')

# CSV.open("./apps.csv", "r") do |csv|
#   h.each do |key, value|
#       csv << [key, value]
#   end
# end

# def get_host_without_www(url)
#   url = "http://#{url}" if URI.parse(url).scheme.nil?
#   host = URI.parse(url).host.downcase
#   host.start_with?('www.') ? host[4..-1] : host
# end

# ENGLISH ONLY
  # array = doc.css('li.language').map { |text| text.text }
  # lang = array[0]
  # # puts lang
  # if (lang == "Language: English")
 	#  puts lang
  # end
  # next