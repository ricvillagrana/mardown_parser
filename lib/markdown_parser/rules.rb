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
      MarkdownParser::LineStyle.apply(line)
    end

    def self.apply_inline_style(line)
      MarkdownParser::InlineStyle.apply(line) 
      # this line adds the last enqueued string for closing tags, like </ul>
      append_queue line
    end

    # toggle boolean variables
    def self.toggle(symbol)
      @state[symbol] = !@state[symbol]
    end

    # set the new value to index of symbol in @state
    def self.set(symbol, value)
      @state[symbol] = value
    end

    # adds at the beginning of the line the string in the @state[:to_append]
    def self.append_queue(line)
      to_append, @state[:to_append] = @state[:to_append], nil
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
        @state[:to_append] = "</ul>"
      end
    end

    def self.state
      @state
    end

  end
end
