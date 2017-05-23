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
    options.host = "localhost"
    options.port = "6379"
    options.keys = 500
    options.delay = 5
    options.tcp_keepalive = 10
    options.reconnect_attempts = 10

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

      opts.on("-r", "--recconect-attempts x", Integer,
              "reconnect-attempts") do |r|
        options.reconnect_attempts = r
      end

      opts.on("-k", "--keepalive x", Integer,
              "Redis tcp keepalive setting") do |k|
        options.tcp_keepalive = k
      end

      opts.on("-v", "--verbose",
              "Verbose") do |v|
        options.verbose = v
      end
    end
    opt_parser.parse!(args)
    options
  end  # parse()

end

options = ParseOpts.parse(ARGV)

redis_options = { host: options[:host], port: options[:port], tcp_keepalive: options[:tcp_keepalive], reconnect_attempts: options[:reconnect_attempts] }

pp redis_options

redis = Redis.new(redis_options)

test_id = SecureRandom.uuid

puts "Test ID: #{test_id}"
puts "Running test of #{options[:keys]} keys with a #{options[:delay]} ms delay"
errors = 0
last_error = false
error_types = []

options[:keys].times do |i|
    begin
        last_error = false
        redis.set("#{test_id}-#{i}", test_id)
    rescue Exception => ex
      errors = errors + 1
      last_error = true
      error_types << ex.class unless error_types.include? ex.class
      puts ex.message if options[:verbose]
    end
    sleep(options[:delay]/1000.0)
end

puts "Insert complete, #{errors} errors encountered, last error #{last_error}, error types: #{error_types}"
