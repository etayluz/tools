require 'nokogiri'
require 'open-uri'
require "csv"
require 'uri'
require 'domainatrix'


doc = Nokogiri::HTML(open("https://itunes.apple.com/us/app/betchlife/id520980062?mt=8"))
array = doc.css('div.app-links a').map { |link| 

	url = link['href'] 
	#   url = "http://#{url}" if URI.parse(url).scheme.nil?
  # host = URI.parse(url).host.downcase
  # url = host.start_with?('www.') ? host[4..-1] : host
url = Domainatrix.parse(url)
url.domain + "." + url.public_suffix


}
array.uniq!
puts array.join(', ')