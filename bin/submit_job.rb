#!/usr/bin/env ruby
require 'json'
require 'fileutils'
require 'securerandom'
require 'openssl'

abort "Usage: submit_job.rb <process.py> <data.csv>" unless ARGV.size == 2

process_file, data_file = ARGV

abort "Process not found" unless File.exist?(process_file)
abort "Data not found" unless File.exist?(data_file)

def encrypt(data, key)
  cipher = OpenSSL::Cipher.new("aes-256-gcm")
  cipher.encrypt
  cipher.key = key
  iv = SecureRandom.random_bytes(12)
  cipher.iv = iv

  encrypted = cipher.update(data) + cipher.final
  {
    iv: iv.unpack1("H*"),
    data: encrypted.unpack1("H*"),
    tag: cipher.auth_tag.unpack1("H*")
  }.to_json
end

FileUtils.mkdir_p("jobs")

job_id = SecureRandom.uuid
key = SecureRandom.random_bytes(32)

File.write("jobs_encrypted/job_#{job_id}.py.enc",
  encrypt(File.read(process_file), key)
)

File.write("data_encrypted/job_#{job_id}.csv.enc",
  encrypt(File.read(data_file), key)
)

File.binwrite("jobs_encrypted/job_#{job_id}.key", key)

puts "[INFO] Job submitted"
puts "  ID: #{job_id}"
puts "  Encrypted key: jobs/job_#{job_id}.key"
puts "  Encrypted process: jobs/job_#{job_id}.py.enc"
puts "  Encrypted data   : data/job_#{job_id}.csv.enc"
puts "  Encrypted output : output/job_#{job_id}.out.enc"
