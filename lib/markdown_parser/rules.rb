module MarkdownParser
  module Rules

    @state = {
      code_tag_opened: false,
      code_tag_hl_opened: false,
      list_opened: false,
      last_was_list: false,
      to_append: nil
    }

    def self.apply(line)
      apply_inline_style(apply_line(line))
    end

    def self.apply_line(line)
      line = EscapeUtils.unescape_html(line)

      before_parse :ensure_to_close_list, line

      return line if @state[:code_tag_opened] and !line.match(/^```$/)

      case line
      when /^#+\s/ # titles
        apply_header(line)
      when /^(------|======)\s*$/ # alternative titles
        apply_header(line)
      when /^(---|___|\*\*\*)\s*$/ # line separator
        "<hr />"
      when /^>\s.+$/ # blockqoutes
        apply_blockquote(line)
      when /^```.*/ # code
        apply_code(line)
      when /^(-|\*|\+|\d+)\s.+/ # list item
        apply_list(line)
      else
        line.empty? ? line : "<p>#{line}</p>"
      end
    end

    def self.apply_inline_style(line)
      # **strong**
      line.gsub!(/\*\*(?<word>[^\*]*)\*\*/, "<strong>\\k<word></strong>")
      # _em_
      line.gsub!(/\_(?<word>[^_]*)\_/, "<em>\\k<word></em>")
      # `code`
      line.gsub!(/`(?<word>[^`]*)`/, "<code>\\k<word></code>")
      # [alt message](image_url)
      line.gsub!(/!\[(?<alt>[^\]]*)\]\((?<link>[^\)]*)\)/, '<img src="\k<link>" alt="\k<alt>" \>')
      # [text](limk)
      line.gsub!(/\[(?<text>[^\]]*)\]\((?<link>[^\)]*)\)/, '<a href="\k<link>">\k<text></a>')

      append_queue line
    end

    # haeder method
    def self.apply_header(line)
      depth = title_depth(line)
      return line if depth > 0
      line.gsub(eval("/^#{'#' * depth}\s/"), "<h#{depth}>").gsub(/$/, "</h#{depth}>")
    end

    # blockquote method
    def self.apply_blockquote(line)
      "<p><blockqouote>#{line}</blockqoute></p>"
    end

    # multi-line code method
    def self.apply_code(line)
      line = @state[:code_tag_opened] ? "</code></pre>" : "<pre><code>"
      toggle(:code_tag_opened)
      line
    end

    # list item method, also add ul tag when is the first to be added
    def self.apply_list(line)
      line = "\t<li>#{line[2..-1]}</li>"
      line = "<ul>\n" + line unless @state[:last_was_list]
      toggle(:list_opened)
      @state[:last_was_list] = true
      line
    end

    # toggle boolean variables
    def self.toggle(symbol)
      @state[symbol] = !@state[symbol]
    end

    # define how many #'s a string has'
    def self.title_depth(str)
      str.match(/^#+\s*/).to_s.size - 1
    end

    # adds at the beginning of the line the string in the @state[:to_append]
    def self.append_queue(line)
      to_append = @state[:to_append]
      @state[:to_append] = nil
      to_append.nil? ? line : to_append + line
    end

    # execute the method passed as symbol and adds the param to it
    def self.before_parse(symbol, param)
      send(symbol, param)
    end

    # check if the last line added was a list and if the current line isn't, so, add a </ul>\n
    def self.ensure_to_close_list(line)
      if @state[:last_was_list] && !['- ', '+ ', '* '].include?(line[0,2])
        @state[:last_was_list] = false
        @state[:to_append] = "</ul>\n"
      end
    end
  end
end
