require 'csv'

class ToolsController < ApplicationController
	def run
		CSV.foreach("../apps.csv", headers: true) do |row|
		  puts row[1]
		  doc = Nokogiri::HTML(open(row[1]))


		  array = doc.css('div.app-links a').map { |link| 

		  	url = link['href'] 
		  	#   url = "http://#{url}" if URI.parse(url).scheme.nil?
			  # host = URI.parse(url).host.downcase
			  # url = host.start_with?('www.') ? host[4..-1] : host
			url = Domainatrix.parse(url)
			url.domain + "." + url.public_suffix


		  }
		  array.uniq!
		  array.each { |url| 
		  	# puts url 
		  	#   url = "http://#{url}" if URI.parse(url).scheme.nil?
			  # host = URI.parse(url).host.downcase
			  # test = host.start_with?('www.') ? host[4..-1] : host
			  puts url
			  # csv << [row[0], row[1], url]
		  }
		  # puts
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
end
