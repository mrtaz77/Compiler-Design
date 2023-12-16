import random

def generate_random_tabs():
    num_tabs = random.randint(0, 5)
    num_spaces = random.randint(0, 10)
 
    return '\t' * num_tabs + ' ' * num_spaces

def main():
    with open("war.txt", "w") as output_file:
        for line_number in range(1, 11):
            line = generate_random_tabs()
            output_line = f"{line}This is line {line_number}\n"
            output_file.write(output_line)

if __name__ == "__main__":
    main()
