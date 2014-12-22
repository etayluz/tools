require 'nokogiri'
require 'open-uri'
require "csv"
require 'uri'
require 'domainatrix'
require 'open-uri'
# doc = Nokogiri::HTML(open("http://itenantonline.com"))
# array = doc.css('div.app-links a').map { |link| 

class EtayClass
	@@threads = 0
	@@emails = []
 	def self.test
 		emails = [];
	    url = 'http://jewsonsitehut.co.uk'
	    begin
			html_string = open(url){|f|f.read}
		rescue
			puts "ERROR"
			return
		end
		# puts html_string
		r = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)     
		the_emails = html_string.scan(r).uniq
		# puts the_emails[0]
		hrefs = []
		emails.concat the_emails

		doc = Nokogiri::HTML(html_string)
		hrefs = doc.css("a").map do |link|
			href = link.attr("href")
			# puts href
			if (!href.nil? && !href.empty? && (!href.downcase.include? ".png") && (!href.downcase.include? "#"))
				# puts url
				# puts href
				begin
			 		URI.join( url, href ).to_s.downcase
			 		
			 	rescue
			 		next
			 	end
			end
		end.compact.uniq
		# STDOUT.puts(hrefs.join("\n"))
		hrefs.reject! {|href| !href.include? url}
		# puts hrefs
		hrefs.uniq!
		# t0 = self.first
		@@threads = hrefs.size
		threads = (1..hrefs.size).map do |i|
			# puts i
  			Thread.new do 
  				
				self.load(hrefs[i])  		
			end
		end
		threads.each {|t| t.join}

		# hrefs.each do |the_url|
		# 	# puts the_url
		# 	t1=Thread.new{self.load(the_url)}
		# 	puts "now"
		# 	t1.join
		# 	# Thread.new do
   #    			# yield
   #    			# self.load(the_url)
   #  		end
			# the_emails = self.load(the_url)
			# puts the_url
			# if (!the_emails.nil?)
			# 	# puts the_emails
			# 	emails.concat the_emails
			# end
			# puts email_addresses
		# end
		# emails.map!{|email| email.downcase.strip}
		# emails.uniq!
		# emails.reject! {|email| email.include? "company."}
		# emails.reject! {|email| email.include? "example."}
		# emails.reject! {|email| email.include? "domain."}
		# puts emails.join(', ')

	end

  # A simple wrapper around the *nix cal command.
  	def self.load(url)
		begin
			html_string = open(url){|f|f.read}
			puts url
		rescue
			html_string = ""
		end
		r = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)     
		emails = html_string.scan(r).uniq
		emails.map!{|c| c.downcase.strip}
		emails.reject! {|email| email.include? "company."}
		emails.reject! {|email| email.include? "example."}
		emails.reject! {|email| email.include? "domain."}
		# puts emails
		if emails.size > 0
			@@emails.concat emails
			# puts emails
			# return emails
		end
		@@threads = @@threads - 1
  		puts @@threads

  		if (@@threads == 0)
  			puts @@emails
  		end
	end
end

# puts EtayClass.test
EtayClass.test

# url =  "https://itunes.apple.com/us/app/mobility/id686285904?mt=8"
# html_string = open(url){|f|f.read}
# puts html_string
# doc = Nokogiri::HTML(html_string)
# puts doc

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