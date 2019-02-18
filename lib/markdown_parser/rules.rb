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
      when /^#+\s/
        apply_header(line)
      when /^(------|======)\s*$/
        apply_header(line)
      when /^(---|___|\*\*\*)\s*$/
        "<hr />"
      when /^>\s.+$/
        "<blockqouote><p>#{line}</p></blockqoute>"
      when /^```.*/
        line = @state[:code_tag_opened] ? "</code></pre>" : "<pre><code>"
        toggle(:code_tag_opened)
        line
      when /^(-|\*|\+|\d+)\s.+/
        apply_list(line)
      else
        line.empty? ? line : "<p>#{line}</p>"
      end
    end

    def self.apply_inline_style(line)
      line.gsub!(/\*\*(?<word>[^\*]*)\*\*/, "<strong>\\k<word></strong>")
      line.gsub!(/\_(?<word>[^_]*)\_/, "<em>\\k<word></em>")
      line.gsub!(/`(?<word>[^`]*)`/, "<code>\\k<word></code>")
      line.gsub!(/!\[(?<alt>[^\]]*)\]\((?<link>[^\)]*)\)/, '<img src="\k<link>" alt="\k<alt>" \>')
      line.gsub!(/\[(?<text>[^\]]*)\]\((?<link>[^\)]*)\)/, '<a href="\k<link>">\k<text></a>')

      append_queue line
    end

    def self.apply_header(line)
      depth = title_depth(line)
      if depth > 0
        line.gsub(eval("/^#{'#' * depth}\s/"), "<h#{depth}>").gsub(/$/, "</h#{depth}>")
      else
        line
      end
    end

    def self.apply_list(line)
      line = "\t<li>#{line[2..-1]}</li>"
      line = "<ul>\n" + line unless @state[:last_was_list]
      toggle(:list_opened)
      @state[:last_was_list] = true
      line
    end

    def self.toggle(symbol)
      @state[symbol] = !@state[symbol]
    end

    def self.title_depth(str)
      str.match(/^#+\s*/).to_s.size - 1
    end

    def self.append_queue(line)
      to_append = @state[:to_append]
      @state[:to_append] = nil
      to_append.nil? ? line : to_append + line
    end

    def self.before_parse(symbol, param)
      send(symbol, param)
    end

    def self.ensure_to_close_list(line)
      if @state[:last_was_list] && !['- ', '+ ', '* '].include?(line[0,2])
        @state[:last_was_list] = false
        @state[:to_append] = "</ul>\n"
      end
    end
  end
end
