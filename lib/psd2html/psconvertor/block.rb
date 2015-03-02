module Psd2html
  module PsConvertor
    class Block < ::Psd2html::Convertor
      def get_classname
        classname = "block-#{guid}"
        return classname
      end
      def get_html_tpl
        "<{{tag}} {{#attributes}} {{key}}=\"{{value}}\" {{/attributes}}><div style=\"position:relative;\">{{{content}}}</div></{{tag}}>"
      end
      def inline_style
        #默认为定位布局
        visibility = @psNode['visible'] == true ? 'initial' : 'none'
        if @parentConvertor.children_layout == 'fluid'
          
        else
          "position:absolute;"+
          "width:#{@psNode.width}px;"+
          "height:#{@psNode.height}px;"+
          "display:#{visibility};"+
          "left:"+curleft+';'+
          "top:"+curtop+';'+
          "z-index:#{@psNode.depth}#{@parentConvertor.childrenConvertors.length - @index.to_i}"
        end
      end
      def html_skeleton
        tag = @parentConvertor.children_tag || 'div'
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