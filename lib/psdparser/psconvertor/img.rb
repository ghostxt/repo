module Psdparser
  module PsConvertor
    class Img < ::Psdparser::Convertor
      def after_init
        @skip = true
        Util.connect_nodes(@parentConvertor, self)
      end
      def get_html_tpl
        "<{{tag}} {{#attributes}} {{key}}=\"{{value}}\" {{/attributes}} />"
      end
      class << self
        def save_image(node,imgUrl)
          if node.type == :group
            node.image.save_as_png(imgUrl)
          else
            node.save_as_png(imgUrl)
          end
        end
        # handle_asynchronously :save_image
      end
      def html_skeleton    
        imgUrl = "#{File.dirname(@dstPath)}/#{guid}.png"
        # imgUrl = "#{File.dirname(@dstPath)}/img-source-#{guid}-#{Time.now.to_i}.png"
        # save_image(@psNode, imgUrl)
        if @psNode.type == :group
          @psNode.image.save_as_png(imgUrl)
        else
          @psNode.save_as_png(imgUrl)
        end
        htmlRenderData = {
          "attributes" => {
            "class" => "img-#{guid}",
            "style" => inline_style,
            "src" => "#{guid}.png"
          },
          "tag" => "img"
        }
        htmlRenderData = HTML_HASH_BASE.merge(htmlRenderData)
      end
    end
  end
end