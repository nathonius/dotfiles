import subprocess
import os

# Set the current working directory
os.chdir("/Users/nathan/devel/pi")

# Run git log command and capture the output
output = subprocess.check_output(["git", "log", "development..", "--oneline"]).decode("utf-8")

# Split the output into lines and reverse the order
lines = output.strip().split("\n")
lines.reverse()

# Format each line as a markdown bulleted list item
markdown_lines = [f"- {line.split(' ', 1)[1]}" for line in lines]

# Print the result
print("\n".join(markdown_lines))
