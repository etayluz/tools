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

	def run
		apps = Apps.order("RANDOM()").where("apps.website IS NULL").take(1)
		apps.map { |app| puts app.name } 

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

		# puts "hello"
		# logger.debug "test"
		# i = 0
		# File.delete('stocks.csv') if File.exist?('stocks.csv')
		# Dir.foreach('../stockList') do |file|
		# 	next if file == '.' or file == '..'
		# 	stock = file.gsub(".csv", "")
		# 	#puts stock
		# 	records_to_insert = []
		# 	File.open('../stockList/'+file).each do |line|
		# 		next if line.include? "Open"
		# 		break if line.include? "doctype"
		# 		info = []
		# 		info = line.split(',')
		# 		#puts array[0]
		# 		record_to_insert = Hash["stock" => stock, "date" => info[0], "open" => info[1], "high" => info[2], 
		# 							 "low" => info[3], "close" => info[4],"volume" => info[5],"adj_close" => info[6]]
		# 		#Stock.create!(record_to_insert)
		# 		#puts row_to_insert
		# 		records_to_insert << Stock.new(record_to_insert)
		# 	end
		# 	#puts records_to_insert
		# 	Stock.import(records_to_insert)			
		# 	# i = i + 1
		# 	# if (i == 2)
		# 	# 	break
		# 	# end
		
end
