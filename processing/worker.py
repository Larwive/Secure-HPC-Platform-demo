import time
import json
import subprocess
import os

while True:
    for job_file in os.listdir("/jobs"):
        with open(f"/jobs/{job_file}") as f:
            job = json.load(f)

        process = job["process"]
        input_file = job["input"]

        output_file = f"/output/{job_file.replace('.json','.out')}"

        with open(output_file, "w") as out:
            subprocess.run(
                ["python", f"/{process}", f"/{input_file}"],
                stdout=out,
                stderr=out
            )

        os.remove(f"/jobs/{job_file}")

    time.sleep(1)
