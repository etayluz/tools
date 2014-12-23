require 'nokogiri'
require 'open-uri'
require "csv"
require 'uri'
require 'domainatrix'
require 'open-uri'
# doc = Nokogiri::HTML(open("http://itenantonline.com"))
# array = doc.css('div.app-links a').map { |link| 

class EtayClass
	@@threads = {}
	@@emails = {}
 	def self.test
 		# emails = [];
	    url = 'http://nomalys.com'
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
		# emails.concat the_emails
		if (the_emails.size > 0)
			if  @@emails[url].nil?
				@@emails[url] = []
			end
			@@emails[url].concat emails
		end
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
		# @@threads = hrefs.size
		url = Domainatrix.parse(url)
		url = url.domain + "." + url.public_suffix
		@@threads[url] = hrefs.size
		# puts "hrefs"
		puts @@threads 
		# puts hrefs
		threads = (0..(hrefs.size-1)).map do |i|
			# puts i
  			Thread.new do 
				self.loadURL(hrefs[i])  		
			end
		end
		# puts "end"
		threads.each {|t| t.join}

	end

  # A simple wrapper around the *nix cal command.
  	def self.loadURL(url)
		begin
			html_string = open(url){|f|f.read}
			# puts "A1"
			puts url
		rescue
			puts url
			puts "failed"
			html_string = ""
		end
		r = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)     
		emails = html_string.scan(r)
		emails.map!{|c| c.downcase.strip}
		emails.uniq!
		emails.reject! {|email| email.include? "company."}
		emails.reject! {|email| email.include? "example."}
		emails.reject! {|email| email.include? "domain."}
		# puts emails
		url = Domainatrix.parse(url)
		url = url.domain + "." + url.public_suffix
		if emails.size > 0
			if  @@emails[url].nil?
				@@emails[url] = []
			end
			@@emails[url].concat emails
			# puts emails
			# return emails
		end

		@@threads[url] = @@threads[url] - 1
  		puts @@threads

  		if (@@threads[url] == 0)
  			if (@@emails.size > 0)
  				puts @@emails
  			else
  				puts "NO EMAILS FOUND"
  			end
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