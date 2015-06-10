module Psdparser
  module PsConvertor
    class Img < ::Psdparser::Convertor
      def after_init
        @skip = true
        @nodeType = "image"
        @attributes["class"] = "img-#{guid}"
        @attributes["src"] = save_image
        Util.connect_nodes(@parentConvertor, self)
      end
      def save_image
        imgUrl = "#{File.dirname(@dstPath)}/img/#{guid}.png"
        if @psNode["type"] == :group
          @psNode.image.save_as_png(imgUrl)
        else
          @psNode.save_as_png(imgUrl)
        end
        log("generate image")
        imgUrl
      end
    end
  end
end