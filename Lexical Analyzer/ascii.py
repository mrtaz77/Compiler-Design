import os

out = ""
for i in range(1,127):
	out += str(hex(i)) + " " + chr(i) + "\n"

script_directory = os.path.dirname(os.path.abspath(__file__))
file_path = os.path.join(script_directory, "ascii.txt")


with open(file_path, "w") as f:
	f.write(out)