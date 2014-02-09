require 'sinatra/base'

module Webhelp

class ObfuscatorMiddleware < Sinatra::Base

  def obfuscate_html_and_css
    ob      = Webhelp::Obfuscator.new
    body    = response.body.join
    obed    = ob.obfuscate_css ob.obfuscate_html body
    deobed  = ob.deobfuscate_html ob.deobfuscate_css obed
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
