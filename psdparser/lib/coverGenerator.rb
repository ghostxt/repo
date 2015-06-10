require 'digest/md5'
require_relative './util.rb'

class CoverGenerator
  def log(content)
    Util.log(content, @logPath)
  end
  
  def initialize(psdPath,dstHtmlPath)
    @psdPath = psdPath
    @dstHtmlPath = dstHtmlPath
    @logPath = "#{File.dirname(@dstHtmlPath)}/#{Digest::MD5.hexdigest(File.read(@psdPath))}.log"
    psd = PSD.new(psdPath)
    psd.parse! 
    imgUrl = "#{File.dirname(@dstHtmlPath)}/img/thumbnail.png"
    log("generate thumbnail start")
    psd.image.save_as_png(imgUrl)
    log("generate thumbnail end")
  end
end