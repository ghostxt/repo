module Psd2html
  module PsConvertor
    class Text < ::Psd2html::Convertor
      def css_skeleton
        customStyle = {}
        @psNode.text[:font][:css].split(";\n").each do |styleString|
          styleKey = styleString.split(":")[0]
          styleValue = styleString.split(":")[1]
          customStyle[styleKey] = css_hook(styleValue)
        end
        cssRenderData = {
          "classname" => "text-#{guid}",
          "styles" => inline_style("array", customStyle)
        }
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