#!/usr/bin/env ruby
# encoding: utf-8

require 'uri'
require 'net/http'
require 'xml'
require_relative 'dbhelper'

def get_station(station)
  
  url = URI.parse('http://reiseauskunft.bahn.de/bin/mgate.exe/dn')
  request = Net::HTTP::Post.new(url.path)

  request.body ="<?xml version='1.0' encoding='utf-8' ?>
  				<ReqC ver='1.1' prod='String' lang='DE'>
  					<LocValReq id='req' maxNr='10' sMode='1'>
  						<ReqLoc type='ALLTYPE' match='#{station}'/>
  					</LocValReq>
  				</ReqC>"

  response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}

  source = XML::Parser.string(response.body)
  content = source.parse

  stations = content.find('//Station')
  
  stationen = Array.new
  
  if stations.length == 1
    station = Station.new(stations[0]["name"])
    station.id = stations[0]["externalStationNr"]
    station.x = stations[0]["x"]
    station.y = stations[0]["y"]
    
    stationen.push(station)
  else
    stations.each do |station|
    
      station = Station.new(station["name"])
      station.id = station["externalStationNr"]
      station.x = station["x"]
      station.y = station["y"]
    
      stationen.push(station)
  
    end
  end


  
  return stationen
  
end


$stdout.puts "Willkommen bei DB_Console\n"
$stdout.puts "1. Abfahrtsmonitor"
$stdout.puts "2. Verbindungssuche"

menu = gets

if menu.chomp.eql? "1"
  
  $stdout.puts "Welche Station?\n"
  userStation = gets
  
  userStationen = get_station(userStation)
  
  if userStationen.empty?
    $stdout.puts "Keine Station vorhanden."
  else
    if userStationen.length > 1
      $stdout.puts "Welche Station soll gewählt werden?"
      i = 0
      userStationen.each do |uStation|
        i = i+1
        $stdout.puts i.to_s() + " #{uStation.name}"
      end
      number = gets
      number = Integer(number)
      userId = userStation[number].id
      userSName = userStationen[number].name
    else
      userId = userStationen[0].id
      userSName = userStationen[0].name
    end
  end
  
  if userId.include? "#80"
    id = userId + '#80'
  else
    id = userId
  end

  t = Time.now
  time = t.strftime("%H:%M:%S")

  $stdout.puts "Abfahrten für : #{userSName} um #{time} \n\n"

  url = URI.parse('http://reiseauskunft.bahn.de/bin/mgate.exe/dn')
  request = Net::HTTP::Post.new(url.path)

  request.body ="<?xml version='1.0' encoding='iso-8859-1'?> 
  				<ReqC ver='1.1' prod='String' lang='de' accessId='???'> 
  					<STBReq boardType='DEP'> 
  						<Time>#{time}</Time> 
  						<Today /> 
  						<TableStation externalId='#{id}'/> 
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

else
  
end