#!/usr/bin/env ruby
# encoding: utf-8

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
      
      
class Station
  
  attr_accessor :name, :id, :x, :y
  
  def initialize(name)
    @name = name
  end
end