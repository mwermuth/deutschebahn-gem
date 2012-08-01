#!/usr/bin/env ruby

require 'uri'
require 'net/http'
require 'xml'


input = ARGV[0]
input2 = ARGV[1]

if (ARGV[0] != nil && ARGV[1] != nil)
	i = ARGV[0]+' '+ARGV[1]
else
	i = ARGV[0]
end




$stdout.puts "Suchergebnisse fuer : #{i} \n\n"

url = URI.parse('http://reiseauskunft.bahn.de/bin/mgate.exe/dn')
request = Net::HTTP::Post.new(url.path)

request.body ="<?xml version='1.0' encoding='utf-8' ?>
				<ReqC ver='1.1' prod='String' lang='DE'>
					<LocValReq id='req' maxNr='10' sMode='1'>
						<ReqLoc type='ALLTYPE' match='#{i}'/>
					</LocValReq>
				</ReqC>"

response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}

source = XML::Parser.string(response.body)
content = source.parse

stations = content.find('//Station')

stations.each do |station|
	$stdout.puts "\t#{station}"
end