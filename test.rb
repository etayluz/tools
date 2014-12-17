require 'nokogiri'
require 'open-uri'
require "csv"
require 'uri'
require 'domainatrix'
require 'open-uri'
# doc = Nokogiri::HTML(open("http://itenantonline.com"))
# array = doc.css('div.app-links a').map { |link| 

class EtayClass
 	def self.test
	    url = 'http://www.asi67.com'
		html_string = open(url){|f|f.read}
		# puts html_string
		r = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)     
		emails = html_string.scan(r).uniq
		puts emails[0]
		hrefs = []
		if emails.size == 0
			doc = Nokogiri::HTML(html_string)
			hrefs = doc.css("a").map do |link|
				href = link.attr("href")
				if (!href.nil? && !href.empty? && (!href.downcase.include? ".png") && (!href.downcase.include? "#"))
				  URI.join( url, href ).to_s
				end
			end.compact.uniq
			# STDOUT.puts(hrefs.join("\n"))
		end
		hrefs.reject! {|href| !href.include? url}
		# puts hrefs
		hrefs.each do |the_url|
			self.load(the_url)
			# puts email_addresses
		end
	end

  # A simple wrapper around the *nix cal command.
  	def self.load(url)
		html_string = open(url){|f|f.read}
		r = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)     
		emails = html_string.scan(r).uniq
		if emails.size > 0
			puts emails[0]
		end
	end
end

# puts EtayClass.test
EtayClass.test



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