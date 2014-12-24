require 'nokogiri'
require 'open-uri'
require "csv"
require 'uri'
require 'domainatrix'
require 'open-uri'
require 'active_record'


class EtayClass
	@threads = 0
	@emails = []
	@website

 	def getEmails(website)
 		@website = website
 		@emails = []
 		@threads = 0
		puts "Start: " + website.website
		url = 'http://' + website.website
	   	# url = 'http://modulo.com' - fix this - not all threads are returning
		# url = 'http://immergas.com' #- emails too long
	    begin
			html_string = open(url, 'r',  :read_timeout=>30){|f|f.read}
		rescue
			getNextWebsite("COULD NOT OPEN URL: " + url) 
			return
		end
		emailRejex = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)   
		begin  
			foundEmails = html_string.scan(emailRejex).uniq
		rescue
			foundEmails = []
		end
		storeEmail(url, foundEmails)
		doc = Nokogiri::HTML(html_string)
		hrefs = []
		hrefs = doc.css("a").map do |link|
			href = link.attr("href")
			# puts href
			if (!href.nil? && !href.empty? && (!href.downcase.include? ".png") && (!href.downcase.include? "#") \
				&& (!href.downcase.include? ".jpg") && (!href.downcase.include? ".pdf") && (!href.downcase.include? ".pdf"))
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
			getNextWebsite(url)
			return
		end
		url = Domainatrix.parse(url)
		url = url.domain + "." + url.public_suffix
		@threads = hrefs.size
		# puts @@threads 
		# puts hrefs
		threads = (0..(hrefs.size-1)).map do |i|
  			Thread.new do 
				loadURL(hrefs[i])  		
			end
		end
		threads.each {|t| t.join}

	end

	def loadURL(url)
		begin
			html_string = open(url, 'r',  :read_timeout=>30){|f|f.read}
			# puts "A1"
			puts @threads
			puts url
		rescue
			puts url
			puts @threads
			puts "COULD NOT OPEN URL: " + url
			html_string = ""
		end
		r = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)  
		begin   
			emails = html_string.scan(r)
		rescue
			emails = []
		end
		url = Domainatrix.parse(url)
		url = url.domain + "." + url.public_suffix
		# puts  @@threads
		# remainingThreads =  @threads
		# if (remainingThreads.class.name.include? "NilClass")
		# 	puts url
		# 	remainingThreads =  @threads
		# 	puts remainingThreads
		# 	puts "Again:" + remainingThreads.class.name
		# 	return
		# end
		# remainingThreads = @threads - 1
		@threads = @threads - 1
		storeEmail(url, emails)
  		if (@threads == 0)
  			if (@emails.size > 0)
  				getNextWebsite(url)
  			else
  				getNextWebsite("NO EMAILS FOUND")
  			end

  		end
	end



	def getNextWebsite(msg)
		if (msg.include? ".")
			# url = msg
			if (@emails.size > 0)
				puts @website.website + ": " + @emails.join(', ')
				@website.email = @emails.join(', ')
				@website.save
			else
				puts "No Emails found"
				@website.email = "zzzzz"
				@website.save
			end

		else
			puts msg
		end
		# getEmailsThread=Thread.new{self.getEmails}
		# getEmailsThread.join
			
	end
  # A simple wrapper around the *nix cal command.

  	def storeEmail(url, emails)
  		# puts url
  		emails.map!{|c| c.downcase.strip}
		emails.uniq!
		emails.reject! {|email| email.include? "company."}
		emails.reject! {|email| email.include? "example."}
		emails.reject! {|email| email.include? "domain."}
		emails.reject! {|email| email.include? ".gif"}
		emails.reject! {|email| email.include? ".jpg"}
		emails.reject! {|email| email.include? ".png"}
		emails.reject! {|email| email.include? ".js"}

		# puts emails
		url = Domainatrix.parse(url)
		url = url.domain + "." + url.public_suffix
		if emails.size > 0
			# puts emails
			if  @emails.nil?
				@emails[url] = []
			end
			@emails.concat emails
			@emails.uniq!
			# if (@@threads[url] == 0)
			# 	puts @@emails
			# end
			# return emails
		end
  	end
end

class Websites < ActiveRecord::Base
end

dbconfig = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)
t0 = Websites.first
while TRUE  do
	websites = Websites.order("RANDOM()").where("websites.email IS NULL").take(1)
	website = websites[0]
	instance = EtayClass.new
	instance.getEmails(website)
end