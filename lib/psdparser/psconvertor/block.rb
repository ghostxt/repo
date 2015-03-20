module Psdparser
  module PsConvertor
    class Block < ::Psdparser::Convertor
      def get_classname
        classname = "block-#{guid}"
        return classname
      end
      def get_html_tpl
        "<{{tag}} {{#attributes}} {{key}}=\"{{value}}\" {{/attributes}}><div style=\"position:relative;\">{{{content}}}</div></{{tag}}>"
      end
      def html_skeleton
        tag = 'div'
        htmlRenderData = {
          "attributes" => {
            "class" => get_classname,
            "style" => inline_style
          },
          "tag" => tag
        }
        if @@html_dictory[get_classname]
          htmlRenderData['attributes'].merge!({
            "style" => htmlRenderData['attributes']['style'] + @@html_dictory[get_classname]['style']
          })
        end
        htmlRenderData = HTML_HASH_BASE.merge(htmlRenderData)
      end
	  		
    end
  end

end