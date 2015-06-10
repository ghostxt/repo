module Psdparser
  module PsConvertor
    class List < ::Psdparser::Convertor
      def sort_list_item(list)
        #从左向右，从上到下的优先级
        list.sort{|a, b| a.left+a.top*100 <=> b.left+b.top*100}
      end
      def get_list_info
        @attributes["class"] = "list-#{guid}"
        @children_layout = "fluid"
        @width = 0;
        @psNode.children = sort_list_item(@psNode.children)
        children = @psNode.children
        #计算列表是否横向排列
        children0 = children[0]
        children1 = children[1]
        if children0.left + children0.width <= children1.left && children0.top + children0.height >= children1.top
          @type = "horizontal"
          @row_item_num = 1
          @vertical_spacing = 10000
          first = children[0]
          children.each_with_index do |item, index|
            unless index == 0
              if first.top + first.height >= item.top
                @row_item_num += 1
              else
                vs = item.top - first.top - first.height
                @vertical_spacing = vs > 0 && vs < @vertical_spacing ? vs : @vertical_spacing
              end
            end
          end
          @width = (100 / @row_item_num.to_f).round(3)
        else
          @type = "vertical"
          @width = 100
        end        
      end
      def html_wrap_child(html)
        "<li>#{html}</li>"
      end
      def after_init
        get_list_info
      end
    end
  end
end