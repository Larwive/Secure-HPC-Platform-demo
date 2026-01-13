import time
import json
import subprocess
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

        # Run by passing through stdin
        try:
            result = subprocess.run(
                ["python", "decrypt.py"],
                input=process_code + b"\n---DATA---\n" + data,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                timeout=60
            )
            output = result.stdout  # bytes
            print(f"[SECURE NODE] Job {job_id} output:\n", output.decode())
        except Exception as e:
            output = bytes(f"Error running job {job_id}: {e}", "utf-8")
            print(output)
    

        aes = AESGCM(key)
        iv = b"\x00" * 12
        encrypted = aes.encrypt(iv, output, None)
        open(f"/output/job_{job_id}.out.enc", "wb").write(encrypted)

        # os.remove(f"/jobs/job_{job_id}.key")
        # os.remove(f"/jobs/job_{job_id}.py.enc")
        # os.remove(f"/data/job_{job_id}.csv.enc")

    time.sleep(1)
