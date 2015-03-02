module Psd2html
  module PsConvertor
    class Text < ::Psd2html::Convertor
      def css_skeleton
        cssRenderData = {
          "classname" => "text-#{guid}",
          "styles" => {
            "position" => "absolute",
            "display" => "inline-block",
            "width" => "#{@psNode.width+2}px",
            "height" => "#{@psNode.height+2}px",
            "left" => curleft,
            "top" => curtop,
            "z-index" => "#{@psNode.depth}#{@parentConvertor.childrenConvertors.length - @index.to_i}"
          }
        }
        # puts @psNode.text[:font][:css]
        @psNode.text[:font][:css].split(";").each do |styleString|
          styleKey = styleString.split(":")[0]
          styleValue = styleString.split(":")[1]
          cssRenderData["styles"][styleKey] = css_hook(styleValue)
        end
        cssRenderData = CSS_HASH_BASE.merge(cssRenderData)
      end
      def html_skeleton
        htmlRenderData = {
          "attributes" => {
            "class" => "text-#{guid}",
          },
          "tag" => "span",
          "content" => @psNode.text[:value]
        }
        htmlRenderData = HTML_HASH_BASE.merge(htmlRenderData)
      end
    end
  end

end