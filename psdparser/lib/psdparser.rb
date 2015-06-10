require 'psd'
require 'json'
require 'delayed_job'
require 'delayed_job_active_record'
require 'digest/md5'
require 'image_optim'
require_relative './util.rb'
require_relative './psdparser/convertor.rb'
Dir.glob( File.expand_path( "psdparser/psconvertor/*.rb", File.dirname(__FILE__) ) ) do |convertor|
  require convertor
end

class PsdParser
  CONVERTING_MAP = {
    "text" => ::Psdparser::PsConvertor::Text,
    "block" => ::Psdparser::PsConvertor::Block,
    "bg" => ::Psdparser::PsConvertor::Background,
    "img" => ::Psdparser::PsConvertor::Img,
    "link" => ::Psdparser::PsConvertor::Link,
    "anim" => ::Psdparser::PsConvertor::Anim,
    "root" => ::Psdparser::PsConvertor::Root
  }
  def log(content)
    Util.log(content, @logPath)
  end
  def initialize(psdPath,dstHtmlPath, outputType)
    require_relative "./transform/#{outputType}.rb"
    @psdPath = psdPath
    @dstHtmlPath = dstHtmlPath
    @logPath = "#{File.dirname(@dstHtmlPath)}/#{Digest::MD5.hexdigest(File.read(@psdPath))}.log"
    log("start parse psd tree....")
    psd = PSD.new(psdPath)
    psd.parse! 
    blockRoot = psd.tree
    rootConvertor = get_convertor(blockRoot,1)
    @treeRoot = format_tree(rootConvertor)
    log("start generate psd tree....")
  end
  def render
    result = OutputFormat.render(@treeRoot)
    log("render finished")
    return result
    # return @treeRoot[':psNode']
  end

  protected  
  def get_convertor(node,index,nodeName = nil, convertor = nil)
    return CONVERTING_MAP["root"].new(node,index,@dstHtmlPath, convertor, @logPath) if node.root? 
    convertorName = Util.getConvertorName(node,nodeName)
    
    unless CONVERTING_MAP.include?(convertorName)
      return
    end
    result = CONVERTING_MAP[convertorName].new(node,index,@dstHtmlPath, convertor, @logPath)
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