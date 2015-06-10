module Psdparser
  module PsConvertor
    class Background < ::Psdparser::Convertor
      def after_init
        customStyle = {
          "background-image" => save_image,
          "background-position" => [@style["left"], @style["top"]],
          "background-size" => [@style["width"], @style["height"]],
          "background-repeat" => "no-repeat"
        }
        parentInfo = @parentConvertor.getNodeInfo
        parentAttr = parentInfo["attributes"]
        parentAttr["style"] = parentAttr["style"].merge(customStyle)
        @skip = true        
      end
      def save_image
        imgUrl = "#{File.dirname(@dstPath)}/img/#{guid}.png"
        if @psNode["type"] == :group
          @psNode.image.save_as_png(imgUrl)
        else
          @psNode.save_as_png(imgUrl)
        end
        imgUrl
      end
      def guid
        "link-" + super
      end
    end
  end
end