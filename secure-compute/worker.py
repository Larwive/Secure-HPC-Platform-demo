import time
import json
import subprocess
import tempfile
import os
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

def decrypt(path, key):
    blob = json.load(open(path))
    aes = AESGCM(key)
    return aes.decrypt(
        bytes.fromhex(blob["iv"]),
        bytes.fromhex(blob["data"]) + bytes.fromhex(blob["tag"]),
        None
    )

while True:
    for job in os.listdir("/jobs"):
        if not job.endswith(".key"):
            continue

        job_id = job.replace("job_", "").replace(".key", "")
        print(f"[SECURE NODE] Processing job {job_id}")

        key = open(f"/jobs/job_{job_id}.key", "rb").read()

        process_code = decrypt(f"/jobs/job_{job_id}.py.enc", key)
        data = decrypt(f"/data/job_{job_id}.csv.enc", key)

        with tempfile.TemporaryDirectory() as tmp:
            process_path = f"{tmp}/process.py"
            data_path    = f"{tmp}/data.csv"
            output_path  = f"{tmp}/output.txt"
        
            # Write decrypted contents
            with open(process_path, "wb") as f:
                f.write(process_code)
            with open(data_path, "wb") as f:
                f.write(data)
        
            # Run the process script exactly like before
            result = subprocess.run(
                ["python", process_path, data_path],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                timeout=60
            )
        
            output = result.stdout  # bytes
            print(f"[SECURE NODE] Job {job_id} output:\n", output.decode())

        aes = AESGCM(key)
        iv = b"\x00" * 12
        encrypted = aes.encrypt(iv, output, None)
        open(f"/output/job_{job_id}.out.enc", "wb").write(encrypted)

        # os.remove(f"/jobs/job_{job_id}.key")
        # os.remove(f"/jobs/job_{job_id}.py.enc")
        # os.remove(f"/data/job_{job_id}.csv.enc")

    time.sleep(1)
