require_relative '../lib/markdown_parser'

RSpec.describe MarkdownParser, '#parse' do
  context 'parse' do
    it 'returns a div when has a empty string' do
      parsed_html = MarkdownParser.parse('')
      expect(parsed_html).to eq "<div class='markdown-parser'></div>"
    end

    it 'returns a div witha p tag when has a text' do
      parsed_html = MarkdownParser.parse('simple text')
      expect(parsed_html).to eq "<div class='markdown-parser'><p>simple text</p></div>"
    end

    it 'returns a div witha h{n} tag when line begins with /#+\n/ pattern' do
      100.times do
        n = (Random.rand * 10).to_i + 1
        parsed_html = MarkdownParser.parse("#{'#' * n} Title")
        expect(parsed_html).to eq "<div class='markdown-parser'><h#{n}>Title</h#{n}></div>"
      end
    end
  end

  context 'apply_rules' do
    it 'parses bold text **bold** => <strong>bold</strong>' do
      expect(MarkdownParser.apply_rules('Some **bold** in text')).to eq '<p>Some <strong>bold</strong> in text</p>'
    end

    it 'adds ul tags automaticlly' do
      expect(MarkdownParser.apply_rules('- first element')).to eq '<ul><li>first element</li>'
      expect(MarkdownParser.apply_rules('- second element')).to eq '<li>second element</li>'
      expect(MarkdownParser.apply_rules('list already ended')).to eq '</ul><p>list already ended</p>'
    end

    it 'adds the link with the correct structure' do
      expect(MarkdownParser.apply_rules('Click [here](link)')).to eq '<p>Click <a href="link">here</a></p>'
    end

    it 'adds the image with the correct structure' do
      expect(MarkdownParser.apply_rules('see ![alt](src)')).to eq '<p>see <img src="src" alt="alt" /></p>'
    end

    it 'adds correctly a blockqoute' do
      expect(MarkdownParser.apply_rules('> block')).to eq '<p><blockquote>block</blockquote></p>'
      expect(MarkdownParser.apply_rules('> block with **bold** text')).to eq '<p><blockquote>block with <strong>bold</strong> text</blockquote></p>'
    end
  end
end
