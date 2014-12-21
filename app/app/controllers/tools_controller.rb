
require 'nokogiri'
require 'open-uri'
require "csv"
require 'uri'
require 'domainatrix'

class ToolsController < ApplicationController

	def migrateWebsites
		apps = Apps.where("apps.website IS NOT NULL")
		apps.each do |app|
			if app.website.include? "NONE"
				next
			end
			if app.website.include? ","
				websites = app.website.split(', ')
				puts websites[0]
				puts websites[1]
			else
				puts app.website
			end
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
		# puts "the" + $websiteName
		apps = Apps.order("RANDOM()").where("apps.email IS NULL AND apps.website != 'NONE' AND apps.website != ?",$websiteName).take(1)
		app = apps[0]
		puts app.website
		website = app.website
		if app.website.include? ","
			websites = app.website.split(',')
			website = websites[0]
		end
		$websiteName = website
		emails = [];
		# website = "aeronet.com"
	    url = 'http://' + website
	    puts url
	    # url = 'http://fca-magazine.com'
	    begin
			html_string = open(url){|f|f.read}
		rescue
			# app.email = "NONE"
			# app.save
			getEmails		
		end
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
			the_emails = self.loadURL(the_url)
			# puts the_url
			if (!the_emails.nil?)
				# puts the_emails
				emails.concat the_emails
			end
			# puts email_addresses
		end
		emails.map!{|email| email.downcase.strip}
		emails.uniq!
		emails.reject! {|email| email.include? "company."}
		emails.reject! {|email| email.include? "example."}
		emails.reject! {|email| email.include? "domain."}
		puts emails.join(', ')
		if (emails.size > 0)
			app.email = emails.join(', ')
		else
			# app.email = "NONE"
			puts "No emails found"
		end
		# app.save
		getEmails
	end

	def loadURL(url)
		puts url
		begin
			html_string = open(url){|f|f.read}
		rescue
			html_string = ""
		end
		r = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)     
		emails = html_string.scan(r).uniq
		# puts emails
		if emails.size > 0
			# puts emails
			return emails
		end
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
