require 'saxerator'
require 'nokogiri'
require 'ox'
require 'memory_profiler'
require 'net/http'

parser = Saxerator.parser(File.new("data/large.xml")) do |config|
  config.adapter = :nokogiri
end

parser.for_tag(:id).each { |id| puts id.to_s }
