out = ""
for i in range(32,127):
    out += str(hex(i)) + " " + chr(i) + "\n"

with open("ascii.txt", "w") as f:
    f.write(out)