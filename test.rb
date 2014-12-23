require 'nokogiri'
require 'open-uri'
require "csv"
require 'uri'
require 'domainatrix'
require 'open-uri'
require 'active_record'


class EtayClass < ActiveRecord::Base
	@@threads = {}
	@@emails = {}

 	def self.getEmails 
	    url = 'http://www.jewsonsitehut.co.uk'
	    begin
			html_string = open(url, 'r',  :read_timeout=>30){|f|f.read}
		rescue
			self.getNextWebsite("COULD NOT OPEN URL") 
			return
		end
		emailRejex = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)     
		foundEmails = html_string.scan(emailRejex).uniq
		self.storeEmail(url, foundEmails)
		doc = Nokogiri::HTML(html_string)
		hrefs = []
		hrefs = doc.css("a").map do |link|
			href = link.attr("href")
			# puts href
			if (!href.nil? && !href.empty? && (!href.downcase.include? ".png") && (!href.downcase.include? "#"))
				begin
			 		URI.join( url, href ).to_s.downcase
			 	rescue
			 		next
			 	end
			end
		end.compact.uniq
		hrefs.reject! {|href| !href.include? url}
		hrefs.uniq!
		# puts hrefs
		# t0 = self.first
		if (hrefs.size == 0)
			self.getNextWebsite(url)
			return
		end
		url = Domainatrix.parse(url)
		url = url.domain + "." + url.public_suffix
		@@threads[url] = hrefs.size
		# puts @@threads 
		# puts hrefs
		threads = (0..(hrefs.size-1)).map do |i|
  			Thread.new do 
				self.loadURL(hrefs[i])  		
			end
		end
		threads.each {|t| t.join}

	end

	def self.getNextWebsite(msg)
		if (msg.include? ".")
			# url = msg
			if (@@emails.size > 0)
				puts @@emails
			else
				puts "No Emails found"
			end

		else
			puts msg
		end
		# self.test		
	end
  # A simple wrapper around the *nix cal command.

  	def self.storeEmail(url, emails)
  		# puts url
  		emails.map!{|c| c.downcase.strip}
		emails.uniq!
		emails.reject! {|email| email.include? "company."}
		emails.reject! {|email| email.include? "example."}
		emails.reject! {|email| email.include? "domain."}
		# puts emails
		url = Domainatrix.parse(url)
		url = url.domain + "." + url.public_suffix
		if emails.size > 0
			puts emails
			if  @@emails[url].nil?
				@@emails[url] = []
			end
			@@emails[url].concat emails
			@@emails[url].uniq!
			if (@@threads[url] == 0)
				puts @@emails
			end
			# return emails
		end
  	end

  	def self.loadURL(url)
		begin
			html_string = open(url){|f|f.read}
			# puts "A1"
			puts @@threads
			puts url
		rescue
			puts url
			puts @@threads
			puts "failed"
			html_string = ""
		end
		r = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)     
		emails = html_string.scan(r)
		url = Domainatrix.parse(url)
		url = url.domain + "." + url.public_suffix
		@@threads[url] = (@@threads[url] - 1)
		self.storeEmail(url, emails)
  		if (@@threads[url] == 0)
  			if (@@emails.size > 0)
  				self.getNextWebsite(url)
  			else
  				self.getNextWebsite("NO EMAILS FOUND")
  			end

  		end
	end
end


dbconfig = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)
EtayClass.getEmails