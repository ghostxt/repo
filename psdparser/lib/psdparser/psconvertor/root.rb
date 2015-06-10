module Psdparser
  module PsConvertor
    class Root < ::Psdparser::Convertor
      def after_init
        @nodeType = "root"
        @attributes["style"] = {
          "width" => @psNode.width,
          "height" => @psNode.height
        }
        imgUrl = "#{File.dirname(@dstPath)}/img/thumbnail.png"
        @attributes["thumbnail"] = imgUrl
      end
    end
  end

end