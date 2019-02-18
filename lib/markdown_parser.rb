module MarkdownParser
  require 'escape_utils'

  require_relative './markdown_parser/rules'

  def self.parse(plain_text)
    text = EscapeUtils.escape_html(plain_text)
    "<div class='markdown-parser'>\n#{markdown_to_html(text)}\n</div>"
  end

  def self.markdown_to_html(text)
    lines = text.split("\n")
    lines << ''
    lines.map do |line|
      apply_rules(line)
    end.join
  end

  def self.apply_rules(line)
    Rules.apply(line) + "\n"
  end
end
