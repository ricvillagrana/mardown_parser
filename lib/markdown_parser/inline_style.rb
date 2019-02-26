module MarkdownParser
  module InlineStyle
    def self.apply(line)
      apply_bold(line)
      apply_italics(line)
      apply_code(line)
      apply_link(line)
      apply_img(line)
    end

    def self.apply_bold(line)
      # **strong**
      line.gsub!(/\*\*(?<word>[^\*]*)\*\*/, "<strong>\\k<word></strong>")
    end

    def self.apply_italics(line)
      # _em_
      line.gsub!(/\_(?<word>[^_]*)\_/, "<em>\\k<word></em>")
    end

    def self.apply_code(line)
      # `code`
      line.gsub!(/`(?<word>[^`]*)`/, "<code>\\k<word></code>")
    end

    def self.apply_link(line)
      # [alt message](image_url)
      line.gsub!(/!\[(?<alt>[^\]]*)\]\((?<link>[^\)]*)\)/, '<img src="\k<link>" alt="\k<alt>" />')
    end

    def self.apply_img(line)
      # [text](limk)
      line.gsub!(/\[(?<text>[^\]]*)\]\((?<link>[^\)]*)\)/, '<a href="\k<link>">\k<text></a>')
    end
    
  end
end
