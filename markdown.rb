#!/usr/bin/env ruby

  require 'rubygems'
  require 'redcarpet'

class ShowMd

  TEMPFILE = "/tmp/markdown.html"

  def initialize( file )
    @body = IO.read( file )
  end

  def markdown
    options = [ :autolink, :no_intraemphasis, :fenced_code, :gh_blockcode]

    File.open( TEMPFILE, "w" ) do |file|
      file.write( RedcarpetCompat.new( @body, *options).to_html )
    end  # do file
  end

  def show
    system("chromium-browser  #{TEMPFILE} &")
  end


end # class

md = ShowMd.new( ARGV[0] )
md.markdown
md.show

# puts RedcarpetCompat.new(ARGF.read,
#         :fenced_code,
#         :hard_wrap,
#         :filter_html,
#         :smart).to_html

