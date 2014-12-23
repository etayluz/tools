
require 'nokogiri'
require 'open-uri'
require "csv"
require 'uri'
require 'domainatrix'

class ToolsController < ApplicationController
	@@threads = 0
	@@websitesNum = 0
	@@firstTime = true
	@@emails = []
	def migrateWebsites
		apps = Apps.where("apps.website IS NOT NULL")
		sites = []
		hash = {}
		apps.each do |app|
			if app.website.include? "NONE"
				next
			end
			if app.website.include? ","
				websites = app.website.split(', ')
				# puts websites[0]
				sites << websites[0].downcase
				# puts websites[1]
				sites << websites[1].downcase
			else
				# puts app.website
				sites << app.website.downcase
			end
		end
		siteUnique = sites.uniq
		siteUnique = siteUnique.sort_by(&:downcase)
		siteUnique.each do |site|
			# puts site
			# puts sites.count(site)
			# hash[site] = sites.count(site)
			record_to_insert = Hash["website" => site, "apps" => sites.count(site)]
			records_to_insert = []
			records_to_insert << Websites.new(record_to_insert)
			Websites.import(records_to_insert)
		end
		# puts hash
		# puts siteUnique
	end

	def loadApps
		CSV.foreach("../apps.csv", headers: true) do |row|
			puts row[1]
			record_to_insert = Hash["name" => row[0], "iTunes" => row[1]]
			records_to_insert = []
			records_to_insert << Apps.new(record_to_insert)
			Apps.import(records_to_insert)
		end
	end

	def loadApps
		CSV.foreach("../apps.csv", headers: true) do |row|
			puts row[1]
			record_to_insert = Hash["name" => row[0], "iTunes" => row[1]]
			records_to_insert = []
			records_to_insert << Apps.new(record_to_insert)
			Apps.import(records_to_insert)
		end
	end

	def getWebsites
		# func1
		t0 = Apps.first
		t1=Thread.new{func1()}
		# t2=Thread.new{func1()}
		# t3=Thread.new{func1()}
		# t4=Thread.new{func1()}
		# t5=Thread.new{func1()}
		# t6=Thread.new{func1()}
		# t1.join
		# t2.join
		# t3.join
		# t4.join
		# t5.join
		# t6.join
	end

	def func1
		apps = Apps.order("RANDOM()").where("apps.website IS NULL").take(1)
		failed = 0
		while apps.size == 1  do
			# puts Thread.current
			# sleep 2 + 3* failed
			puts failed
			app = apps[0]
			puts app.name
			puts app.iTunes
			begin
	 			doc = Nokogiri::HTML(open(app.iTunes))
	 			failed = failed - 1 if failed > 0
	 		rescue
	 			puts "CONNECTION ERROR - RETRY"
	 			apps = Apps.order("RANDOM()").where("apps.website IS NULL").take(1)
	 			# app.website = "RETRY"
	 			# app.save
	 			if failed == 2
	 				quit
	 			end
	 			failed = failed + 1
	 			next
	 		end
	 		# puts doc
	 		array = doc.css('div.app-links a').map { |link| 
				url = link['href'] 
				url = Domainatrix.parse(url)
				url.domain + "." + url.public_suffix
	 	  	}
	 	 	array.uniq!
	 	 	if (array.size > 0)
	 	 		app.website = array.join(', ')
	 	 		puts app.website
	 	 	else
	 	 		app.website = "NONE"
	 	 	end
	 	 	app.save
	 	 	apps = Apps.order("RANDOM()").where("apps.website IS NULL").take(1)
	 	 	# break;
		end 
	end

	def getEmails
		@@threads = 0
		if (@@firstTime)
			@@firstTime = false
			t0 = Apps.first
		end
		puts "before"
		websites = Websites.order("RANDOM()").where("websites.email IS NULL").take(1)
		puts "after"
		website = websites[0]

 		emails = [];
	    url = 'http://' + website.website
	    puts url
	    begin
			html_string = open(url){|f|f.read}
		rescue
			puts "ERROR"
			self.getEmails()
			return
		end
		# if (@@threads < 5)
  # 			t1=Thread.new{self.getEmails()}
  # 			t1.join
  # 		end
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
		if (hrefs.size == 0)
 			if (@@emails.size > 0)
  				puts @@emails.join(', ')
  				@@emails = []
  			else
  				puts "NO EMAILS FOUND"
  			end
  			# ActiveRecord::Base.connection.close
  			self.getEmails()
  			return
		end
		@@threads = hrefs.size
		threads = (1..hrefs.size).map do |i|
			# puts i
  			Thread.new do 
				self.loadURL(hrefs[i])  		
			end
		end
		threads.each {|t| t.join}
	end

	def loadURL(url)
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
		emails.uniq!
		# puts emails
		if emails.size > 0
			@@emails.concat emails
			@@emails.uniq!
			# puts emails
			# return emails
		end
		# @lock = Mutex.new
		# @lock.synchronize do

			@@threads = @@threads - 1
	  		puts @@threads


	  		if (@@threads == 0)
	  			if (@@emails.size > 0)
	  				puts @@emails.join(', ')
	  				@@emails = []
	  			else
	  				puts "NO EMAILS FOUND"
	  			end
	  			# ActiveRecord::Base.connection.close
	  			self.getEmails()
	  		end
  		# end
	end

	def run
		apps = Apps.order("RANDOM()").where("apps.website IS NULL").take(1)
		if (apps.size == 1)
			puts app[0].name
		end
		# CSV.foreach("../apps.csv", headers: true) do |row|
		# puts row[1]
	 #  	doc = Nokogiri::HTML(open(row[1]))
	 # 	array = doc.css('div.app-links a').map { |link| 
		#   	url = link['href'] 
		# 	url = Domainatrix.parse(url)
		# 	url.domain + "." + url.public_suffix
	 #  	}
	 #  	array.uniq!
		# record_to_insert = Hash["name" => row[0], "iTunes" => row[1], "website" => array.join(', ')]
		# records_to_insert = []
		# records_to_insert << Apps.new(record_to_insert)
		# Apps.import(records_to_insert)
	end
		
end
