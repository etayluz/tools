require 'nokogiri'
require 'open-uri'
require "csv"
require 'uri'
require 'domainatrix'
require 'open-uri'
# doc = Nokogiri::HTML(open("http://itenantonline.com"))
# array = doc.css('div.app-links a').map { |link| 
url = 'http://app-roved.com'
html_string = open(url){|f|f.read}
email_addresses = html_string.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i)
puts email_addresses
hrefs = []
if email_addresses.nil?
	doc = Nokogiri::HTML(html_string)
	hrefs = doc.css("a").map do |link|
		href = link.attr("href") 
		if ((!href.include? "https://") && !href.nil? && !href.empty? && (!href.downcase.include? ".png") && (!href.downcase.include? "#"))
		  url + '/' + href
		end
	end.compact.uniq
	puts hrefs
	# STDOUT.puts(hrefs.join("\n"))
end
puts hrefs

# puts hrefs

# puts 

# 	url = link['href'] 
	#   url = "http://#{url}" if URI.parse(url).scheme.nil?
  # host = URI.parse(url).host.downcase
  # url = host.start_with?('www.') ? host[4..-1] : host
# url = Domainatrix.parse(url)
# url.domain + "." + url.public_suffix


# }
# array.uniq!
# puts array.join(', ')