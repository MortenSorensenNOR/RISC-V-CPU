def convert_to_little_endian(hex_str):
    """Convert a 32-bit hexadecimal string to little-endian format."""
    return '\n'.join(reversed([hex_str[i:i+2] for i in range(0, len(hex_str), 2)]))

def extract_and_convert_file(input_file_path, output_file_path):
    """
    Extracts hexadecimal instruction values from the input file,
    converts them to little-endian format, and writes to an output file.
    """
    with open(input_file_path, 'r') as infile, open(output_file_path, 'w') as outfile:
        for line in infile:
            parts = line.split()
            if len(parts) > 1:
                # Check if the second part is a valid hex instruction
                instruction = parts[1]
                if len(instruction) == 8 and all(c in '0123456789abcdefABCDEF' for c in instruction):
                    little_endian = convert_to_little_endian(instruction)
                    outfile.write(little_endian + '\n')

if __name__ == "__main__":
    import argparse

    # Create an argument parser for command-line usage
    parser = argparse.ArgumentParser(description="Convert hexadecimal instructions to little-endian format.")
    parser.add_argument("input_file", help="Path to the input file containing the code.")
    parser.add_argument("output_file", help="Path to the output file where the converted code will be saved.")

    # Parse the arguments
    args = parser.parse_args()

    # Call the function with provided file paths
    extract_and_convert_file(args.input_file, args.output_file)

    print(f"Converted instructions saved to {args.output_file}.")
