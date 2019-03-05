module MarkdownParser
  module LineStyle
    def self.apply(line)
      return "#{line}\n" if MarkdownParser::Rules.state[:code_tag_opened] and !line.match(/^```$/)

      return apply_header(line) if line.match(/^#+\s/ )
      return '<hr />' if line.match(/^(---|___|\*\*\*)\s*$/)
      return apply_blockquote(line) if line.match(/^>\s.+$/)
      return apply_code(line) if line.match(/^```.*/)
      return apply_list(line) if line.match(/^(-|\*|\+|\d+)\s.+/)

      line.empty? ? line : "<p>#{line}</p>"
    end

    # haeder method
    def self.apply_header(line)
      depth = title_depth(line)
      return line if depth == 0
      line.gsub(eval("/^#{'#' * depth}\s/"), "<h#{depth}>").gsub(/$/, "</h#{depth}>")
    end

    # define how many #'s a string has'
    def self.title_depth(str)
      str.match(/^#+\s*/).to_s.size - 1
    end

    # blockquote method
    def self.apply_blockquote(line)
      "<p><blockquote>#{line[2..-1]}</blockquote></p>"
    end

    # multi-line code method
    def self.apply_code(line)
      lang = line.size > 3 ? line[3..-1] : ''
      line = MarkdownParser::Rules.state[:code_tag_opened] ? "</pre>" : "<pre class='prettyprint #{lang}'>"
      MarkdownParser::Rules.toggle(:code_tag_opened)
      line
    end

    # list item method, also add ul tag when is the first to be added
    def self.apply_list(line)
      line = "<li>#{line[2..-1]}</li>"
      line = "<ul>" + line unless MarkdownParser::Rules.state[:last_was_list]
      MarkdownParser::Rules.set(:list_opened, true)
      MarkdownParser::Rules.set(:last_was_list, true)
      line
    end

  end
end
