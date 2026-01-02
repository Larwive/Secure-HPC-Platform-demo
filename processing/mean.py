import sys
import csv

if len(sys.argv) != 2:
    print("Usage: mean.py <input_file>")
    sys.exit(1)

input_file = sys.argv[1]
values = []

with open(input_file, newline="") as f:
    reader = csv.reader(f)
    for row in reader:
        try:
            values.append(float(row[0]))
        except ValueError:
            print(f"Error: Invalid value '{row[0]}' in input file.")
            sys.exit(1)

print(f"Processed {len(values)} values.")
if values:
    print(f"Mean: {sum(values) / len(values)}")
