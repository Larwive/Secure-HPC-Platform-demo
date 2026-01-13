#!/usr/bin/env ruby
require 'json'
require 'fileutils'
require 'securerandom'
require 'openssl'
require 'io/console'

abort "Usage: submit_job.rb <process.py> <data.enc>" unless ARGV.size == 2

# The user authenticates to decrypt the used data. It will fail if the password is wrong.
# There is no username verification. There was verification but it won't work with a wrong password anyway.

process_file, data_file = ARGV
abort "Process not found." unless File.exist?(process_file)
abort "Data not found." unless File.exist?(data_file)


def ask_username
  print "Username : "
  u = STDIN.gets&.strip
  abort("Invalid username") if u.nil? || u.empty?
  u
end

def ask_password
  print "Password : "
  p = STDIN.noecho(&:gets)&.chomp
  puts
  abort("Password is required.") if p.nil? || p.empty?
  p
end

def decrypt_file(path, password)
  payload = JSON.parse(File.read(path))
  salt = [payload["salt"]].pack("H*")
  key = OpenSSL::PKCS5.pbkdf2_hmac(password, salt, 200_000, 32, "sha256")

  cipher = OpenSSL::Cipher.new("aes-256-gcm")
  cipher.decrypt
  cipher.key = key
  cipher.iv = [payload["iv"]].pack("H*")
  cipher.auth_tag = [payload["tag"]].pack("H*")

  cipher.update([payload["data"]].pack("H*")) + cipher.final
end

def encrypt(data, key)
  cipher = OpenSSL::Cipher.new("aes-256-gcm")
  cipher.encrypt
  cipher.key = key
  iv = cipher.random_iv
  cipher.iv = iv

  encrypted = cipher.update(data) + cipher.final

  {
    iv: iv.unpack1("H*"),
    data: encrypted.unpack1("H*"),
    tag: cipher.auth_tag.unpack1("H*")
  }.to_json
end

username = ask_username
password = ask_password

FileUtils.mkdir_p("jobs")

job_id = SecureRandom.uuid
key = SecureRandom.random_bytes(32)

File.write("jobs_encrypted/job_#{job_id}.py.enc",
  encrypt(File.read(process_file), key)
)

# Decrypt data (with password) then re-encrypt with job key
decrypted_data = decrypt_file(data_file, password)
File.write("data_encrypted/job_#{job_id}.csv.enc", encrypt(decrypted_data, key))

# Store key (unciphered for this demo)
File.binwrite("jobs_encrypted/job_#{job_id}.key", key)

puts "[INFO] Job submitted"
puts "  ID: #{job_id}"
puts "  User: #{username}"
puts "  Encrypted key: jobs/job_#{job_id}.key"
puts "  Encrypted process: jobs/job_#{job_id}.py.enc"
puts "  Encrypted data   : data/job_#{job_id}.csv.enc"
puts "  Encrypted output : output/job_#{job_id}.out.enc"
