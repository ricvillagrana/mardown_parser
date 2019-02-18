require_relative './lib/markdown_parser'

puts MarkdownParser.parse(File.read('test.md'))
