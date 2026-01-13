import sys


def separate_script_data(input_str):
    return input_str.split(b"\n---DATA---\n")

def execute(script, data):
    exec(script, {"data": data})

input_str = sys.stdin.buffer.read()
execute(*separate_script_data(input_str))
