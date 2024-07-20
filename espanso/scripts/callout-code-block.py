import pyperclip

def generate_markdown_quote_block():
    clipboard_contents = pyperclip.paste()
    lines = clipboard_contents.split('\n')
    indented_lines = [f"> {line}" for line in lines]
    indented_contents = '\n'.join(indented_lines)
    markdown_quote_block = f"> [!Codeblock]- Code\n> ~~~\n{indented_contents}\n> ~~~"
    return markdown_quote_block

if __name__ == "__main__":
    markdown_quote = generate_markdown_quote_block()
    print(markdown_quote)
