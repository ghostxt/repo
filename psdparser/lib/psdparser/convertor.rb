require "mustache"
require 'digest/md5'
module Psdparser
    class Convertor
        attr_accessor :psNode, :index, :childrenConvertors,:parentConvertor, :convertor, :skip, :nodeType, :style, :attributes, :nodeInfo, :children_layout, :logPath
        def initialize(psNode,index,dstPath,convertor, logPath)
            before_init
            @psNode = psNode
            @index = index
            @parentConvertor = convertor
            @childrenConvertors = []
            @dstPath = dstPath
            @nodeInfo = {}
            @logPath = logPath
            @nodeType = ""
            if convertor
                @style = inline_style
            else
                @style = {}
            end
            @attributes = {
                "style" => @style
            }            
            after_init
        end
        def log(content)
          Util.log(content, @logPath)
        end
        def inline_style(customStyle = {})
          visibility = @psNode[:visible] == true ? 'initial' : 'none'
          if @parentConvertor.children_layout == 'fluid'
            style = {
              "position" => "relative",
              "display" => visibility,
              "width" => @psNode.width+2,
              "height" => @psNode.height+2,
              "z-index" => "#{@psNode.depth}#{@parentConvertor.psNode.children.length - @index.to_i}".to_i
            }
          else
            style = {
              "position" => "absolute",
              "display" => visibility,
              "width" => @psNode.width+2,
              "height" => @psNode.height+2,
              "left" => curleft,
              "top" => curtop,
              "z-index" => "#{@psNode.depth}#{@parentConvertor.psNode.children.length - @index.to_i}".to_i
            }
          end
          # style = style.merge(Util.parseEffects(@psNode))
        end
        
        def getNodeInfo
            @nodeInfo = @nodeInfo.merge({
              'nodeType' => @nodeType,
              'attributes' => @attributes
            })
            children = []
            if @psNode.has_children?
                @childrenConvertors.each_with_index do |node,index|
                    children << node.getNodeInfo
                end
                @nodeInfo[:children] = children
            end
            @nodeInfo
        end
        
        def guid
            if @psNode.name.include?("|")
                className = @psNode.name.split("|")[0]
            else
                className = @psNode.name
            end
            guidStr = className+@index.to_s
            Digest::MD5.hexdigest(guidStr)
        end

        def before_init
        end
        def after_init
        end
        
        def curleft
            wrapleft = @parentConvertor.psNode.respond_to?("left") ? parentConvertor.psNode.left : 0
            @psNode.left-wrapleft
        end
        def curtop
            wraptop = @parentConvertor.psNode.respond_to?("top") ? parentConvertor.psNode.top : 0
            @psNode.top-wraptop
        end
    end
end
