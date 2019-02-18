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

      case line
      when /^#+\s/
        apply_header(line)
      when /^(------|======)\s*$/
        apply_header(line)
      when /^(---|___|\*\*\*)\s*$/
        "<hr />"
      when /^>\s.+$/
        "<blockqouote><p>#{line}</p></blockqoute>"
      when /\[.+\]\(https?:\/\/.+\)/
        apply_link(line)
      when /^```$/
        line = @state[:code_tag_opened] ? "</code></pre>" : "<pre><code>"
        toggle(:code_tag_opened)
        line
      when /^```$/
        "<code><pre>"
      when /```(ruby|javascript|php)/
        line = @state[:code_tag_hl_opened] ? "</code></pre>" : "<pre><code>"
        toggle(:code_tag_hl_opened)
        line
      when /^(-|\*|\+|\d+)\s.+/
        apply_list(line)
      else
        line
      end
    end

    def self.apply_inline_style(line)
      to_return = case line
      when /\*\*.+\*\*/
        "<p><strong>#{line[2..-3]}</strong></p>"
      when /\_.+\_/
        "<p><em>#{line[1..-2]}</em></p>"
       when /`/
        "<code>#{line}</code>"
      else
        line
      end

      append_queue to_return
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

    def self.apply_link(line)
      text = /\[.+\]/.match(line).to_s[1..-2]
      link = /\(.+\)/.match(line).to_s[1..-2]
      "<p><a href='#{link}'>#{text}</a></p>"
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
