#!/usr/bin/env ruby

require 'uri'
require 'net/http'
require 'xml'

i = ARGV[0] + '#80'

$stdout.puts "Abfahrten fuer : #{i} \n\n"

url = URI.parse('http://reiseauskunft.bahn.de/bin/mgate.exe/dn')
request = Net::HTTP::Post.new(url.path)

request.body ="<?xml version='1.0' encoding='iso-8859-1'?> 
				<ReqC ver='1.1' prod='String' lang='de' accessId='???'> 
					<STBReq boardType='DEP'> 
						<Time>19:50:11</Time> 
						<Today /> 
						<TableStation externalId='#{i}'/> 
						<ProductFilter>1111111111111111</ProductFilter> 
					</STBReq> 
				</ReqC>"

response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}

source = XML::Parser.string(response.body)
content = source.parse

stationboardentries = content.find('//StationBoardEntry')

stationboardentries.take(10).each do |stationboardentry|
	$stdout.puts "\t#{stationboardentry}"
end
