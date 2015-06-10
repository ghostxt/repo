Dir.glob( File.expand_path( "./*.rb", File.dirname(__FILE__) ) ) do |convertor|
  require convertor
end
module Psdparser
  module PsConvertor
    attr_accessor :children
    
    class Anim < ::Psdparser::Convertor
      CONVERTING_MAP = {
        "text" => ::Psdparser::PsConvertor::Text,
        "img" => ::Psdparser::PsConvertor::Img,
      }
      def replaceGroupLayer
        Util.connect_nodes(@parentConvertor, @childrenConvertors[0])
      end
      
      def parseNode(node)
        return CONVERTING_MAP[Util.getConvertorName(node)].new(node,@index,@dstHtmlPath, @parentConvertor, @logPath)
      end
      
      def formatAnim(elements)
        anim = []
        compareData = {
          "top" => 1,
          "left" => 1,
          "width" => 1,
          "height" => 1,
          "opacity" => 1,
          "rotate" => 1
        }
        if elements[0]["nodeType"] == "text"
          compareData = compareData.merge({
            "color" => 1,
            "font-size" =>1
            })
          end
          elements.each_with_index do |elem,index|
            tmp = {}
            compareData.keys.each_with_index do |name, index|
              tmp["#{name}"] = elem["attributes"]["style"][name]
            end
            anim.push(tmp)
          end
          elements[0]["attributes"]["anim"] = anim
          return anim
        end
      
        def parseChildren
          @childrenConvertors = []
          psNode.children.each_with_index do |child,index|
            type = child.to_hash[:type]
            if type == :layer && !child.text.nil?
              convertorName = "text"
            else
              convertorName = "img"
            end 
            @childrenConvertors.push(parseNode(child))
          end
        
        end
      
        def after_init
          @skip = true
          @anim = []
          parseChildren
          formatAnim(getNodeInfo[:children])
          replaceGroupLayer
        end
      
      
      end
    end
  end