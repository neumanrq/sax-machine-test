require 'sax-machine'

class SAXParser
  include SAXMachine
  element :title
end

parser = SAXParser.new
io_read, io_write = IO.pipe
parser_thread = Thread.new { parser.parse(io_read) }
open('large.xml') { |f| puts (c = f.read); io_write << c }

parser_thread.join
sleep
