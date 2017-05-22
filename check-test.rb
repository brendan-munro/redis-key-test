#!/usr/bin/env ruby
#
# Run redis key instertion
#

require 'redis'
require 'optparse'
require 'ostruct'
require 'pp'
require 'SecureRandom'

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

      opts.on("-h", "--host x", String,
              "Redis host") do |h|
        options.host = h
      end

      opts.on("-p", "--port x", Integer,
              "Redis port") do |p|
        options.port = p
      end

      opts.on("-i", "--test-id x", String,
              "Test ID") do |i|
        options.test_id = i
      end

      opts.on("-c", "--clean",
              "Test ID") do |c|
        options.clean = c
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

test_id = options[:test_id]

puts "Test ID: #{test_id}"
puts "Verifying test of #{options[:keys]} keys"
good_values = 0

options[:keys].times do |i|
    result = redis.get("#{test_id}-#{i}")
    good_values = good_values + 1 if result == test_id
    redis.del("#{test_id}-#{i}") if options[:clean]
end

puts "Found #{good_values}/#{options[:keys]}"
