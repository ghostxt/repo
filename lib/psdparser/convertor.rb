require "mustache"
require 'digest/md5'
require_relative '../util.rb'
module Psdparser
  class Convertor
    #children_layout: 子节点布局，绝对定位或流式布局
    #children_tag: 子节点标签
    attr_accessor :psNode, :index, :childrenConvertors,:parentConvertor, :convertor, :children_layout, :children_tag, :skip

    CSS_TPL = "\.{{classname}}\{ \n{{#styles}} {{key}}:{{value}};\n{{/styles}}  \}"
    CSS_HASH_BASE = {
      "classname" => 'root-container',
      "styles" => {
        "position" => "relative"
      }
    }
    @@css_dictory = {

    }
    
    HTML_TPL = "<{{tag}} {{#attributes}} {{key}}=\"{{value}}\" {{/attributes}}>{{{content}}}</{{tag}}>"
    HTML_HASH_BASE = {
      "attributes" => {
        "class" => "root-container"
      },
      "tag" => "div",
      "content" => ""
    }
    @@html_dictory = {
        
    }
      
    def initialize(psNode,index,dstPath,convertor)
      before_init
      @psNode = psNode
      @index = index
      @parentConvertor = convertor
      @childrenConvertors = []
      @dstPath = dstPath
      after_init
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
      "#{@psNode.left-wrapleft}px"
    end
    def curtop
      wraptop = @parentConvertor.psNode.respond_to?("top") ? parentConvertor.psNode.top : 0
      "#{@psNode.top-wraptop}px"
    end
    
    #需要（可以）被重写的方法 start
    def css_skeleton
      CSS_HASH_BASE
    end
    def html_skeleton
      HTML_HASH_BASE
    end
    def get_css_tpl
      CSS_TPL
    end
    def get_html_tpl
      HTML_TPL
    end
    def html_wrap_child(html)
      html
    end
    def css_wrap(css)
      css
    end
    ### end
    
    #为了处理css的同名问题，需要使用一个hash来去重
    def css_map
      Util.log("start generate css of #{@psNode.name}...")
      return unless css_skeleton
      data = css_skeleton.clone
      data["styles"] = Util.hash_to_array(data["styles"])
      data["convertnode"] = self
      @@css_dictory[data["classname"]] = data
      @childrenConvertors.each do |node|
        node.css_map
      end
    end
    def render_css
      css_map()
      cssStr = ""
      @@css_dictory.values.each do |cssData|
        cssStr += "\n" + Mustache.render(cssData['convertnode'].get_css_tpl,cssData)
      end
      @@css_dictory = {}
      cssStr
    end
    
    def inline_style(type = "string", customStyle = {})
      #默认布局为绝对定位布局
      #默认输出为字符串(一般字符串用于node element attribute内容, hash用于style tag中的内容)
      #[可选]传入customStyle参数可扩展样式
      visibility = @psNode['visible'] == true ? 'initial' : 'none'
      if @parentConvertor.children_layout == 'fluid'
        style = {
          "position" => "relative",
          "width" => "#{@psNode.width+2}px",
          "height" => "#{@psNode.height+2}px",
          "left" => 0,
          "top" => 0
        }
      else
        style = {
          "position" => "absolute",
          "display" => "inline-block",
          "width" => "#{@psNode.width+2}px",
          "height" => "#{@psNode.height+2}px",
          "left" => curleft,
          "top" => curtop,
          "z-index" => "#{@psNode.depth}#{@parentConvertor.childrenConvertors.length - @index.to_i}"
        }        
      end
      style = style.merge(customStyle);
      if type == "string"
        cssStr = ""
        Util.hash_to_array(style).each do |cssData|
          cssStr += Mustache.render("{{key}}:{{value}};",cssData)
        end
        cssStr
      else
        style
      end
    end
    
    def render_html
      Util.log("start generate html of #{@psNode.name}...")
      return "" unless html_skeleton
      data = html_skeleton.clone
      data["attributes"] = Util.hash_to_array(data["attributes"])
      @childrenConvertors.each do |node|
        data["content"] += html_wrap_child(node.render_html)
      end
      htmlStr = Mustache.render(get_html_tpl,data)
    end
  end
end