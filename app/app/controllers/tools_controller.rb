require 'nokogiri'
require 'open-uri'
require "csv"
require 'uri'
require 'domainatrix'

class ToolsController < ApplicationController
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
		while apps.size == 1  do
			puts Thread.current
			app = apps[0]
			puts app.name
			puts app.iTunes
			begin
	 			doc = Nokogiri::HTML(open(app.iTunes))
	 		rescue
	 			puts "CONNECTION ERROR - RETRY"
	 			next
	 		end
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
