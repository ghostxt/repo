require 'psd'
require 'json'
require 'delayed_job'
require 'delayed_job_active_record'
require_relative './Util.rb'
require_relative 'psd2html/convertor.rb'
Dir.glob( File.expand_path( "psd2html/psconvertor/*.rb", File.dirname(__FILE__) ) ) do |convertor|
  require convertor
end

class Psd2Html
  CONVERTING_MAP = {
    "ignore" => ::Psd2html::PsConvertor::Ignore,
    "text" => ::Psd2html::PsConvertor::Text,
    "link" => ::Psd2html::PsConvertor::Link,
    "list" => ::Psd2html::PsConvertor::List,
    "block" => ::Psd2html::PsConvertor::Block,
    "img" => ::Psd2html::PsConvertor::Img,
    "bg" => ::Psd2html::PsConvertor::Background,
    "root" => ::Psd2html::PsConvertor::Root
  }
  def initialize(psdPath,dstHtmlPath)
    @dstHtmlPath = dstHtmlPath
    psd = PSD.new(psdPath)
    psd.parse! 
    blockRoot = psd.tree
    rootConvertor = get_convertor(blockRoot,1)
    @treeRoot = format_tree(rootConvertor)
    Util.log("start generate psd tree....")
  end

  def render_css
    Util.log("start render css....")
    return @treeRoot.render_css
  end
  def render_html
    Util.log("start render html....")
    return @treeRoot.render_html
  end

  def render
    return <<-STR
    <!doctype html>
    <html lang="en">
    <head>
    <meta charset="UTF-8" />
    <title>Document</title>
    <style type="text/css">
    *{margin:0;padding:0;border:0;}
    #{@treeRoot.render_css}
    </style>
    </head>
    <body>
    #{@treeRoot.render_html}
    </body>
    </html>
    STR
  end

  protected
  def get_convertorname(node,nodeName = nil)
    type = node.to_hash[:type]
    name = nodeName || node.name
    if name.include?("|")
      convertorName = name.split('|').last.to_s
    elsif type == :group 
      convertorName = "block"
      # elsif type == :layer && !node.text.nil?
      #   node.image.save_as_png('../tmp.png');
      #   convertorName = "text"
    else
      convertorName = "img"
    end 
  end
  def get_convertor(node,index,nodeName = nil, convertor = nil)
    return CONVERTING_MAP["root"].new(node,index,@dstHtmlPath, convertor) if node.root? 

    convertorName = get_convertorname(node,nodeName)
    
    unless CONVERTING_MAP.include?(convertorName)
      return
    end
    result = CONVERTING_MAP[convertorName].new(node,index,@dstHtmlPath, convertor)
    if result.skip
      return
    end
    result
  end
  def format_tree(convertor)
    if convertor.psNode.has_children?
      convertor.psNode.children.each_with_index do |node,index|
        childConvertor = get_convertor(node,index, nil, convertor)
        if childConvertor
          Util.connect_nodes(convertor, format_tree(childConvertor))
        end
      end
    end
    convertor
  end
end