module Psdparser
  module PsConvertor
    class NewName
      def initialize(name)
        @name = name
      end
      def data
        @name
      end
    end
    class Link < ::Psdparser::Convertor
      def after_init
        tmp_node = @psNode.clone
        name_str = Util.remove_last_modifier(psNode.name)
        name = NewName.new(name_str)
        tmp_node.adjustments[:name] = name
        self.psNode.children = [tmp_node]
        # Util.connect_nodes(@convertor, self)
      end
      def guid
        "link-" + super
      end
      def html_skeleton
        cssData = "position:absolute;"+
          "width:#{@psNode.width}px;"+
          "height:#{@psNode.height}px;"+
          "left:"+curleft+';'+
          "top:"+curtop+';'+
          "z-index:#{@psNode.depth}#{@parentConvertor.childrenConvertors.length - @index.to_i}"
        
        htmlRenderData = {
          "attributes" => {
            "class" => "#{guid}",
            "style" => cssData,
            "href" => "#"
          },
          "tag" => "a",
        }
        htmlRenderData = HTML_HASH_BASE.merge(htmlRenderData)
      end
    end
  end

end