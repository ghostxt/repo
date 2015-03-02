#TODO 貌似应该在这里创建li标签
module Psd2html
	module PsConvertor
  	class List < ::Psd2html::Convertor
      def get_classname
        classname = "list-#{guid}"
        return classname
      end
      def sort_list_item(list)
        list.sort{|a, b| a.left+a.top*100 <=> b.left+b.top*100}
      end
      def get_list_info
        @children_tag = "li"
        @children_layout = "fluid"
        @width = 0;
        @psNode.children = sort_list_item(@psNode.children)
        children = @psNode.children
        #计算列表是否横向排列
        children0 = children[0]
        children1 = children[1]
        if children0.left + children0.width <= children1.left && children0.top + children0.height >= children1.top
          @type = "horizontal"
          @row_item_num = 0
          children.each_with_index do |item, index|
            unless index == 0
              first = children[0]
              if first.top + first.height >= item.top
                @row_item_num += 1
              end
            end
          end
          @width = (100 / @row_item_num.to_f).round(3)
        else
          @type = "vertical"
          @width = 100
        end        
      end
      
      def after_init
        get_list_info
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
      def css_skeleton
        cssRenderData = {
          "classname" => get_classname,
          "styles" => {
            "position" => "absolute",
            "display" => "block",
            "width" => "#{@psNode.width}px",
            "height" => "#{@psNode.height}px",
            "left" => curleft,
            "top" => curtop,
            "z-index" => "#{@psNode.depth}#{@parentConvertor.childrenConvertors.length - @index.to_i}"
          }
        }
        cssRenderData = CSS_HASH_BASE.merge(cssRenderData)
        cssRenderData = {
          "classname" => get_classname+' li',
          "styles" => {
            "position" => "relative",
            "display" => "inline-block",
            "width" => "#{@width}%",
            "height" => "#{@psNode.height}px"
          }
        }
        cssRenderData = CSS_HASH_BASE.merge(cssRenderData)
      end
      def html_skeleton
        htmlRenderData = {
          "attributes" => {
            "class" => get_classname,
            "style" => inline_style
          },
          "tag" => 'ul'
        }
        htmlRenderData = HTML_HASH_BASE.merge(htmlRenderData)
      end
	  		
  	end
  end

end