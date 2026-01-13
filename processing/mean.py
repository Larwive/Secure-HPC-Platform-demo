import sys

data: bytes

values = []
for value in data.split(b"\n"):
    try:
        values.append(float(value))
    except ValueError:
        print(f"Error: Invalid value '{value}' in input file.")
        sys.exit(1)

print(f"Processed {len(values)} values.")
if values:
    print(f"{sum(values) / len(values)}")
