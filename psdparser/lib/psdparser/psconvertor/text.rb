module Psdparser
  module PsConvertor
    class Text < ::Psdparser::Convertor
      def after_init
        @nodeType = "text"
        @attributes["class"] = "text-#{guid}"
        extend_style
        @nodeInfo = @nodeInfo.merge({
          "children" => @psNode.text[:value]
        })
      end
      def extend_style
        customStyle = {}
        @psNode.text[:font][:css].split(";\n").each do |styleString|
          styleKey = styleString.split(":")[0]
          styleValue = styleString.split(":")[1]
          customStyle[styleKey] = Util.css_hook(styleValue)
        end
        @attributes['style'] = @attributes['style'].merge(customStyle)
      end
    end
  end

end