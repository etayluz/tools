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
		puts "START: " + website.website
		url = 'http://' + website.website
	   	# url = 'http://modulo.com' - fix this - not all threads are returning
		# url = 'http://immergas.com' #- emails too long
		# url = 'http://aafcleveland.com' # why is this failing?
		# url = 'http://rikcorp.jp' # why is this failing?
		# url = 'http://http://bitwavesolutions.com/' # why can't I get an email out of this one?
		begin
			html_string = open("http://www.google.com", 'r',  :read_timeout=>5){|f|f.read}
		rescue
			puts "COULD NOT CONNECT TO INTERNET"
			return
		end

	    begin
			html_string = open(url, 'r',  :read_timeout=>30){|f|f.read}
		rescue
			puts "COULD NOT OPEN URL: " + url
			getNextWebsite
			return
		end
		emailRejex = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)   
		begin  
			foundEmails = html_string.scan(emailRejex).uniq
		rescue
			foundEmails = []
		end
		storeEmail(foundEmails)

		begin
			doc = Nokogiri::HTML(html_string)
		rescue
			puts "COULD NOT PARSE HTML: " + url
			getNextWebsite
			return
		end
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
		while (hrefs.size > 400) do
			hrefs.delete_at(hrefs.size-1)
		end
		# puts hrefs
		# t0 = self.first
		if (hrefs.size == 0)
			getNextWebsite
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
		@threads = @threads - 1
		storeEmail(emails)
  		if (@threads == 0)
			getNextWebsite
  		end
	end


	def getNextWebsite
		begin
			html_string = open("http://www.google.com", 'r',  :read_timeout=>5){|f|f.read}
		rescue
			puts "COULD NOT CONNECT TO INTERNET"
			return
		end

		if (@emails.size > 0)
			puts @website.website + ": " + @emails.join(', ')
			@website.email = @emails.join(', ')
			@website.save
		else
			puts @website.website + ": NO EMAILS FOUND"
			@website.email = "zzzzz"
			@website.save
		end
	end

  	def storeEmail(emails)
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
		emails.reject! {|email| email.include? "email.com"}
		emails.reject! {|email| email.include? "ourbusiness.com"}
		emails.reject! {|email| email.include? "youremail"}
		emails.reject! {|email| email.include? "mail.com"}

		# puts emails
		if emails.size > 0
			@emails.concat emails
			@emails.uniq!
		end
  	end

  	def getTheEmails()
		while TRUE do
			websites = Websites.order("RANDOM()").where("websites.email IS NULL").take(1)
			if (websites.size == 0)
				puts "DONE"
				break
			end
			website = websites[0]
			getEmails(website)
		end
	end

	def markForeignWebsites
		websites = Websites.where("websites.email IS NOT NULL and websites.email != 'zzzzz'")
		suffixes = []
		totalEmails = 0
		totalGmail = 0
		emailBatch = []
		websites.each do |website|
			url = Domainatrix.parse(website.website)
			if ((url.public_suffix == "com" || url.public_suffix == "net" || url.public_suffix == "us" || 
				  url.public_suffix == "info" || url.public_suffix == "biz"))
				emails =  website.email.split(", ")
				emails.reject! { |email|
					!((email.include? ".com") || (email.include? ".net") ||  (email.include? ".us") || (email.include? ".tv") || (email.include? ".io")) \
					|| (email.include? ".com.") || (email.include? ".uk.") || (email.include? "toyota")
				}
				while (emails.size > 10) do
					emails.delete_at(emails.size-1)
				end
				if (emails.size > 0)
					# puts website.website.upcase
					# puts emails.join(", ")
					totalEmails += emails.size
					emails.each { |email|
						if email.include? "gmail"
							# totalGmail += 1
							# puts email
						end
					}
					emailBatch.concat emails
					# if emailBatch.size > 480
					# 	# puts emailBatch.join(", ")
					# 	# puts
					# 	 emailBatch.each {  |email| File.open("emails.txt", 'a') { |file| file.write(email + ", ") } }
					# 	 File.open("emails.txt", 'a') { |file| file.write("\n\n") }
					# 	# File.open("emails.txt", 'w') { |file| file.write("\n") }

					# 	emailBatch = []
					# end
				end
				# puts "total = " + total.to_s
				# suffixes << url.public_suffix
			end

		end
		# puts "Done"
		emailBatch.uniq!
		emailBatch.each_with_index {  |email, index_num| 
			# puts index_num
			File.open("emails.txt", 'a') { |file| 
				file.write(email + ", ") 
				# puts email
				if (index_num % 500 == 499)
					# puts index_num
					file.write("\n\n") 
				end
		} 
}
		# puts totalGmail
		# puts totalEmails
		# suffixes.uniq!
		# puts suffixes

	end
end

class Websites < ActiveRecord::Base
end

dbconfig = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)
t0 = Websites.first
instance = EtayClass.new
instance.markForeignWebsites
# instance.getTheEmails

