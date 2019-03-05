module MarkdownParser
  module InlineStyle
    def self.apply(line)
      apply_bold(line)
      apply_italics(line)
      apply_code(line)
      apply_image(line)
      apply_link(line)
    end

    def self.apply_bold(line)
      # **strong**
      line.gsub!(/(^|\s+)\*\*(?<word>[^\*]*)\*\*($|\s+)/, "<strong>\\k<word></strong>")
    end

    def self.apply_italics(line)
      # _em_
      line.gsub!(/(^|\s+)\_(?<word>[^_]*)\_($|\s+)/, "<em>\\k<word></em>")
    end

    def self.apply_code(line)
      # `code`
      line.gsub!(/`{1}(?<word>[^`]*)`{1}/, "<code>\\k<word></code>")
    end

    def self.apply_image(line)
      # [alt message](image_url)
      line.gsub!(/!\[(?<alt>[^\]]*)\]\((?<link>[^\)]*)\)/, "<img src='\\k<link>' alt='\\k<alt>' />")
    end

    def self.apply_link(line)
      # [text](limk)
      line.gsub!(/\[(?<text>[^\]]*)\]\((?<link>[^\)]*)\)/, "<a href='\\k<link>' target='_blank'>\\k<text></a>")
    end
    
  end
end
