require 'nokogiri'
require 'open-uri'

files = Dir.entries("ios-business")

files.each { |file|  
	# puts file
	doc = Nokogiri::HTML(open('./ios-business/' + file))
	# puts doc
	h = {}
	doc.xpath('//a[@href]').each do |link|
		if (link['href'].include? "https://itunes.apple.com/us/app/")
	  		h[link.text.strip] = link['href']
	  	end
	end
	# puts h

	h.each do |key, value|
	    puts key + ' : ' + value
	end
}
# doc = Nokogiri::HTML(open('./ios-business/id6000-mt=8&letter=A&page=2.html'))
# https://itunes.apple.com/us/app
# l = doc.css('a').map { |link| link['href'] }
# puts l

# h = {}
# doc.xpath('//a[@href]').each do |link|
# 	if (link['href'].include? "https://itunes.apple.com/us/app/")
#   		h[link.text.strip] = link['href']
#   	end
# end
# # puts h

# h.each do |key, value|
#     puts key + ' : ' + value
# end

# puts doc
# puts 'curl https://itunes.apple.com/us/genre/ios-business/id6000?mt=8&letter=A&page=1#page'
# puts "Hello World"
# line_num=0
# stock = 0
# i = 0
# File.open('Russel3000.txt').each do |line|
# 	i = i + 1
# 	#puts "#{i}"
#   	#print "#{line}"
#   	line  = line.strip
#   	puts "curl -o stockList/#{line}.csv http://ichart.finance.yahoo.com/table.csv?s=#{line}&a=01&b=19&c=1990&d=04&e=04&f=2014&g=d&ignore=.csv"
#   	`curl -o stockList/#{line}.csv http://ichart.finance.yahoo.com/table.csv?s=#{line}&a=01&b=19&c=1990&d=04&e=04&f=2014&g=d&ignore=.csv`
#   	stock = line
#   	#if i == 100
#   	#	break
# end
# print stock
# `curl -o stockList/#{stock}.csv http://ichart.finance.yahoo.com/table.csv?s=#{stock}&a=01&b=19&c=1990&d=04&e=04&f=2014&g=d&ignore=.csv`