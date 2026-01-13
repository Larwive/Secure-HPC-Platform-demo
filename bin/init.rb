require "fileutils"
require "io/console"
require "json"
require "securerandom"
require "openssl"
require "time"

# Here the user sets themselves an account with their own ciphered data.

print "Set an username : "
username = STDIN.gets&.strip
abort("Invalid username.") if username.nil? || username.empty?

print "Set a password : "
password = STDIN.noecho(&:gets)&.chomp
puts

base_dir = "/database_enc/users/#{username}"
FileUtils.mkdir_p(base_dir)

db_id = "db_#{Time.now.strftime("%Y%m%d_%H%M%S")}_#{SecureRandom.hex(4)}"
db_path = File.join(base_dir, db_id)
FileUtils.mkdir_p(db_path)

puts "Ciphering data for #{username}"
puts "→ #{db_path}"

# Generate a key from password
salt = SecureRandom.random_bytes(16)
key = OpenSSL::PKCS5.pbkdf2_hmac(password, salt, 200_000, 32, "sha256")

Dir["/data/*"].each do |file|
  plaintext = File.read(file)
  cipher = OpenSSL::Cipher.new("aes-256-gcm")
  cipher.encrypt
  cipher.key = key
  iv = cipher.random_iv
  cipher.iv = iv
  encrypted = cipher.update(plaintext) + cipher.final
  tag = cipher.auth_tag

  payload = {
    iv: iv.unpack1("H*"),
    salt: salt.unpack1("H*"),  # for later password usage
    tag: tag.unpack1("H*"),
    data: encrypted.unpack1("H*")
  }

  File.write(File.join(db_path, File.basename(file) + ".enc"), JSON.pretty_generate(payload))
end

# Index of users for future username verification ? It's currently useless.
index_path = "/database_enc/index.json"
index = File.exist?(index_path) ? JSON.parse(File.read(index_path)) : {}

index[username] ||= []
index[username] << {
  "db_id" => db_id,
  "created_at" => Time.now.utc.iso8601
}

File.write(index_path, JSON.pretty_generate(index))

puts "Done."
