#!/usr/bin/env ruby
#
# Run redis key instertion
#

require 'redis'
require 'optparse'
require 'ostruct'
require 'pp'
require 'securerandom'

class ParseOpts

  CODES = %w[iso-2022-jp shift_jis euc-jp utf8 binary]
  CODE_ALIASES = { "jis" => "iso-2022-jp", "sjis" => "shift_jis" }

  #
  # Return a structure describing the options.
  #
  def self.parse(args)
    # The options specified on the command line will be collected in *options*.
    # We set default values here.
    options = OpenStruct.new
    options.library = []
    options.inplace = false
    options.encoding = "utf8"
    options.transfer_type = :auto
    options.verbose = false

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: run-test.rb [options]"

      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-n", "--num-keys x", Integer,
              "Number of keys to insert") do |keys|
        options.keys = keys
      end

      opts.on("-d", "--delay x", Integer,
              "Delay between key insertion in ms") do |delay|
        options.delay = delay
      end

      opts.on("-h", "--host x", String,
              "Redis host") do |h|
        options.host = h
      end

      opts.on("-p", "--port x", Integer,
              "Redis port") do |p|
        options.port = p
      end
    end

    opt_parser.parse!(args)
    options
  end  # parse()

end

options = ParseOpts.parse(ARGV)
pp options
pp ARGV

redis_options = { host: options[:host], port: options[:port] }

redis = Redis.new(redis_options)

puts redis.ping

test_id = SecureRandom.uuid

puts "Test ID: #{test_id}"
puts "Running test of #{options[:keys]} keys with a #{options[:delay]} ms delay"

options[:keys].times do |i|
    redis.set("#{test_id}-#{i}", test_id)
    sleep(options[:delay]/1000.0)
end

puts "Insert complete"
