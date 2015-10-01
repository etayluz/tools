require 'nokogiri'
require 'open-uri'
require 'uri'
require 'domainatrix'


websites = []

text=File.open('iot.txt').read
File.open("output.txt", 'w') { |file| "" }

text.gsub!(/\r\n?/, "\n")
text.each_line do |line|
	doc = Nokogiri::HTML(open(line))
	# l = doc.css('div.listwebsite a').map { |link| link['href'] }
	links = doc.css('a')#.map {|link| link.attribute('href').to_s unless link.attribute('href').to_s.include? "Website"}
	links.each do |link|
		if link.inner_html.include? "Website"
			website = link.attribute('href').to_s

			url = Domainatrix.parse(website)
			url = url.domain + "." + url.public_suffix
			
			if url.length > 1
				File.open("output.txt", 'a') { |file| file.write("info@" + url + "\n") }
			end
			# website.slice! "http://"
			# website.slice! "https://"
			# website.slice! "www."
			# website.slice! "/"

			# websites << website
		end
	end
end

# File.open("output.txt", 'w') { |file| file.write(websites) }

# puts websites
   