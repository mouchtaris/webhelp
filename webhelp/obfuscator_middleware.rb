require 'sinatra/base'

module Webhelp

class ObfuscatorMiddleware < Sinatra::Base

  # Separates a string into non-script and script sections.
  # For example
  #   <html>
  #     <head>
  #       <title>T</title>
  #       <script>var a;</script>
  #     </head>
  #     <body>
  #       <script>var b;</script>
  #     </body>
  #   </html>
  # should be split to
  #   [
  #     [
  #       "<html>\n  <head>\n    <title>T</title>\n    ",
  #       "\n  </head>\n  <body>\n    ",
  #       "\n  </body>\n</html>"
  #     ],
  #     [
  #       "<script>var a;</script>",
  #       "<script>var b;</script>"
  #     ]
  #   ]
  def self.separate_script_sections str
    clean = []
    scripts = []
    split1 = str.split %r,(?=<script[^>]*>),
    clean << split1.shift
    for split in split1 do
      split2 = split.split %r,(?<=</script>),, -1
      raise "Split2 expects the string to be split to exactly 2." +
          "What is going on? #{{str: str, clean: clean,
          scripts: scripts, split1: split1, split: split,
          split2: split2}.to_json}" unless split2.length == 2
      scripts << split2[0]
      clean << split2[1]
    end
    [clean, scripts]
  end

  # @param clean_sections [Array<String>]
  # @param script_sections [Array<String>]
  # @return [String]
  #     clean[0] + script[0] + clean[1] + ...
  def self.join_clean_and_script_sections clean_sections, script_sections
    raise ArgumentError.new("not(clean_sections.length - script_sections.length <= 1)") \
        unless clean_sections.length - script_sections.length <= 1
    result = ''
    clean_sections.zip script_sections do |clean, script|
      result << clean
      result << script if script
    end
    result
  end

  def obfuscate_html_and_css
    ob      = Webhelp::Obfuscator.new
    body    = response.body.join
    clean, script = ObfuscatorMiddleware.separate_script_sections body
    obed_sections = clean.map do |sec|
                      begin
                        ob.obfuscate_html sec
                      rescue => e
                        raise "#{sec}\n\n---#{e}\n#{PP.pp ob, ''}"
                      end
                    end.
                    map do |sec|
                      begin
                        ob.obfuscate_css sec
                      rescue => e
                        raise "#{sec}\n\n---#{e}\n#{PP.pp ob, ''}"
                      end
                    end
    obed    = ObfuscatorMiddleware.join_clean_and_script_sections obed_sections, script
    deobed_sections = obed_sections.map do |sec| ob.deobfuscate_html ob.deobfuscate_css sec end
    deobed  = ObfuscatorMiddleware.join_clean_and_script_sections deobed_sections, script
    unless body == deobed then
      require 'diffy'
      diff = Diffy::Diff.new(body, deobed)
      body = haml   "!!!\n"                               +
                    "%html\n"                             +
                    "  %head\n"                           +
                    "    %title Obfuscation Error\n"      +
                    "    :css\n"                          +
                    Diffy::CSS.each_line.map { |line|
                    "      #{line}" }.join                +
                    "  %body\n"                           +
                    "    %h1 Obfuscation Error\n"         +
                    "    %p Please check the diff below\n"+
                    "    :plain\n"                        +
                    diff.to_s(:html).each_line.map { |line|
                    "      #{line}" }.join
      halt 500, body
    end
    self.body obed
  end

  after do
    case response.content_type
      when %r{^text/html} then obfuscate_html_and_css
    end
  end#after

end#class ObfuscatorMiddleware

end#module Webhelp
