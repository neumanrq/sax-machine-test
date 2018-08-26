require 'sax-machine'
require 'net/http'
require 'memory_profiler'
SAXMachine.handler = :nokogiri


class Diverter

  # Wrap block into a forked
  # Ruby process. End process
  # after execution and therefore
  # force handing back
  # memory to the OS
  #
  # Original credit for this idea:
  # Alexander Dymo's popular book "Ruby Performance Optimization"
  def initialize(condition: true)
    return unless block_given?

    if !!condition
      pid = fork do
        yield
        exit!(0)
      end

      # ensure the child process has terminated
      Process::waitpid(pid)
    else
      yield
    end
  end

end

class ItemsParser
  include SAXMachine
  element :id do |value|
    # Print out ID valu to screen to "prove" reading
    # it. Flush back memory for the printing process,
    # we do not want to count it
    #Diverter.new do
      #print "<item><id>#{value}</id></item>"
    #end
  end
end

class SAXParser
  include SAXMachine
  elements :item, class: ItemsParser
end

report = MemoryProfiler.report do
  uri               = URI("http://localhost:3034")
  parser            = SAXParser.new
  io_read, io_write = IO.pipe
  parser_thread     = Thread.new { parser.parse(io_read) }

  Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) do |http|
    request = Net::HTTP::Get.new uri.request_uri
    http.request(request) do |response|
      response.read_body do |chunk|
        io_write << (chunk.force_encoding('utf-8'))
      end

      io_write.close
      parser_thread.join # Wait for parser to finish
    end
  end
end

report.pretty_print

puts "--> Done!"
