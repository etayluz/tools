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
 		emails = [];
	    url = 'http://iktissadonline.com'
		html_string = open(url){|f|f.read}
		# puts html_string
		r = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)     
		the_emails = html_string.scan(r).uniq
		# puts the_emails[0]
		hrefs = []
		emails.concat the_emails

		if emails.size == 0
			doc = Nokogiri::HTML(html_string)
			hrefs = doc.css("a").map do |link|
				href = link.attr("href")
				if (!href.nil? && !href.empty? && (!href.downcase.include? ".png") && (!href.downcase.include? "#"))
					# puts url
					# puts href
					begin
				 		URI.join( url, href ).to_s
				 		
				 	rescue
				 		next
				 	end
				end
			end.compact.uniq
			# STDOUT.puts(hrefs.join("\n"))
		end
		hrefs.reject! {|href| !href.include? url}
		# puts hrefs
		hrefs.each do |the_url|
			the_emails = self.load(the_url)
			# puts the_url
			if (!the_emails.nil?)
				# puts the_emails
				emails.concat the_emails
			end
			# puts email_addresses
		end
		emails.uniq!
		puts emails.join(', ')

	end

  # A simple wrapper around the *nix cal command.
  	def self.load(url)
		html_string = open(url){|f|f.read}
		r = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)     
		emails = html_string.scan(r).uniq
		# puts emails
		if emails.size > 0
			# puts emails
			return emails
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