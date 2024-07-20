import sys
import re

# Regular expression pattern
pattern = r'\b([A-Z]{2}-\d+)\b'

# Extract ticket portion
def extract_ticket(string):
    match = re.search(pattern, string)
    if match:
        return match.group(1)
    else:
        return None

# Get string argument from command line
if len(sys.argv) > 1:
    input_string = sys.argv[1]
    ticket = extract_ticket(input_string)
    if ticket:
        print(ticket)
    else:
        print("No ticket ID found.")
else:
    print("Please provide a string argument.")
