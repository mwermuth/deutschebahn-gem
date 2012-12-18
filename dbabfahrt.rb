#!/usr/bin/env ruby
# encoding: utf-8

require 'uri'
require 'net/http'
require 'xml'

class Abfahrt
  
  @@max_name ||= 0  
  @@max_time ||= 0  
  @@max_type ||= 0
  @@max_direction ||= 0
  
  attr_accessor :name, :id, :type, :category, :product, :direction, :date, :time, :platform
  
  def initialize(name, id, type, time, direction)
    @name = name
    @id = id
    @type = type
    @time = time
    @direction = direction
    
    @@max_name = set_max(@name.length, @@max_name)  
    @@max_time = set_max(@time.length, @@max_time)  
    @@max_type = set_max(@type.length, @@max_type)
    @@max_direction = set_max(@direction.length, @@max_direction)
  end
  
  def printOutput
    $stdout.puts "#{@name} - \t\t#{@time}: #{@type} in Richtung #{@direction}"
  end
  
  def set_max(current, max)
      current > max ? current : max
    end

    def self.max_name  
      @@max_name  
    end  

    def self.max_time  
      @@max_time  
    end  

    def self.max_type  
      @@max_type  
    end  
    
    def self.max_direction  
      @@max_direction  
    end  
  
end
      

  


if ARGV[0].include? "#80"
  i = ARGV[0] + '#80'
else
  i = ARGV[0]
end

if ARGV[1] == nil
  t = Time.now
  time = t.strftime("%H:%M:%S")
else
  time = ARGV[1]
end

$stdout.puts "Abfahrten für : #{i} um #{time} \n\n"

url = URI.parse('http://reiseauskunft.bahn.de/bin/mgate.exe/dn')
request = Net::HTTP::Post.new(url.path)

request.body ="<?xml version='1.0' encoding='iso-8859-1'?> 
				<ReqC ver='1.1' prod='String' lang='de' accessId='???'> 
					<STBReq boardType='DEP'> 
						<Time>#{time}</Time> 
						<Today /> 
						<TableStation externalId='#{i}'/> 
						<ProductFilter>1111111111111111</ProductFilter> 
					</STBReq> 
				</ReqC>"

response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}

source = XML::Parser.string(response.body)
content = source.parse

stationboardentries = content.find('//StationBoardEntry')

abfahrten = Array.new

stationboardentries.take(10).each do |stationboardentry|
  station = stationboardentry.children.find { |node| node.name == "Station" }
  if station != nil
    abfahrt = Abfahrt.new(station["name"], station["externalStationNr"], stationboardentry["name"],  stationboardentry["scheduledTime"], stationboardentry["direction"])
    abfahrt.category = stationboardentry["category"]
    abfahrt.product = stationboardentry["product"]
    date = stationboardentry["scheduledDate"]
    abfahrt.date = date[6..7]+"."+date[4..5]+"."+date[0..3]
    abfahrt.platform = stationboardentry["scheduledPlatform"]
    
    abfahrten.push(abfahrt)
  end
end

format="%#{Abfahrt.max_type}s\t%#{Abfahrt.max_time}s\t%#{Abfahrt.max_direction}s\t%#{Abfahrt.max_name+4}s\n"
printf(format, "Typ", "Zeit", "Richtung", "Station")
printf(format, "---", "----", "--------", "-------")
abfahrten.each do |a|
    printf(format, a.type, a.time, a.direction, a.name)
end



