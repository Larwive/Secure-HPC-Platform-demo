#!/usr/bin/env ruby
require 'json'
require 'fileutils'
require 'securerandom'

if ARGV.length != 2
  puts "Usage: submit_job.rb <process.py> <data.csv>"
  exit 1
end

process_file = ARGV[0]
data_file    = ARGV[1]

# Allowed processes
ALLOWED_PROCESSES = ["processing/mean.py"]

unless ALLOWED_PROCESSES.include?(process_file)
  puts "Error: unauthorized process #{process_file}"
  exit 1
end

unless File.exist?(process_file)
  puts "Error: process not found: #{process_file}"
  exit 1
end

unless File.exist?("#{data_file}")
  puts "Error: data file not found: #{data_file}"
  exit 1
end

FileUtils.mkdir_p("jobs")

job_id = SecureRandom.uuid
job = {
  id: job_id,
  process: process_file,
  input: data_file,
  submitted_at: Time.now.to_s
}

job_path = "jobs/job_#{job_id}.json"
File.write(job_path, JSON.pretty_generate(job))

puts "[INFO] Job submitted"
puts "  ID      : #{job_id}"
puts "  Process : #{process_file}"
puts "  Data    : #{data_file}"
puts "  Job file: #{job_path}"
puts "  Output  : output/job_#{job_id}.out"
