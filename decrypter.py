import sys
import json
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

def decrypt_json(path, key):
    blob = json.load(open(path))
    aes = AESGCM(key)
    return aes.decrypt(
        bytes.fromhex(blob["iv"]),
        bytes.fromhex(blob["data"]) + bytes.fromhex(blob["tag"]),
        None
    )

def decrypt_raw(path, key):
    aes = AESGCM(key)
    encrypted = open(path, "rb").read()
    iv = b"\x00" * 12  # must match worker.py
    return aes.decrypt(iv, encrypted, None)

if len(sys.argv) != 2:
    print("Usage: decrypter.py <job_id>")
    sys.exit(1)

job_id = sys.argv[1]

key_path    = f"jobs/job_{job_id}.key"
proc_path   = f"jobs/job_{job_id}.py.enc"
data_path   = f"data/job_{job_id}.csv.enc"
out_path    = f"output/job_{job_id}.out.enc"

key = open(key_path, "rb").read()

print("\n=== KEY ===")
print(key.hex())

print("\n=== PROCESS ===")
print(decrypt_json(proc_path, key).decode())

print("\n=== DATA ===")
print(decrypt_json(data_path, key).decode())

print("\n=== OUTPUT ===")
print(decrypt_raw(out_path, key).decode())
