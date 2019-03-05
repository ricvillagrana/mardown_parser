Gem::Specification.new do |s|
  s.name        = 'markdown_parser'
  s.version     = '0.1.0.alpha3'
  s.date        = '2019-03-05'
  s.summary     = 'Parses markdown to html'
  s.description = "A gem that parses your markdown to html"
  s.authors     = ["Ricardo Villagrana"]
  s.email       = 'ricardovillagranal@gmail.com '
  s.files       = ["lib/markdown_parser.rb",
                   "lib/markdown_parser/rules.rb",
                   "lib/markdown_parser/inline_style.rb",
                   "lib/markdown_parser/line_style.rb"]
  s.homepage    = 'https://github.com/ricvillagrana/mardown_parser'
  s.license       = 'MIT'
end
