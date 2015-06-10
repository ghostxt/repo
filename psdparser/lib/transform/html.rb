class OutputFormat  
  attr_accessor :result, :maxWidth, :maxHeight, :ratio, :root, :zIndex, :extStyle
  def self.convertImagePath(path)
    path.gsub('./files/1/','./')
  end
  def self.formatChild(node)
    if node[:children] && node[:children].length > 0
      arr = []
      style = node["attributes"]["style"];
      node[:children].each_with_index do |child,index|
        arr.push(format(child))
      end
      return arr.join()
    end
  end
  def self.formatChildPlain(node)
    if node[:children] && node[:children].length > 0
      arr = []
      style = node["attributes"]["style"];
      node[:children].each_with_index do |child,index|
        if style["left"] && style["top"]
          child["attributes"]["style"]["left"] +=  style["left"]
          child["attributes"]["style"]["top"] +=  style["top"]
        end
        arr.push(format(child))
      end
      return arr.join()
    end
  end
  def self.format(node)
    node["nodeType"]
    data = convert(node)
    return data
  end
  def self.scale(num)
    return num.round
    # return (num * @ratio).round
  end
  
  def self.parseAnim(anim, className)
    step = (100 / (anim.length - 1)).to_i
    str = "@-webkit-keyframes #{className}{"
    anim.each_with_index do |item, index|
      str += "#{index * step}%{#{self.stringifyStyle(item)}}"
    end
    str += "}.#{className}{-webkit-animation: #{className} 5s;}"
    @extStyle += str
  end
  
  def self.stringifyStyle(style)
    str = ""
    if style["font-size"]
      str = "font-size:#{scale(style["font-size"].to_i)}px;font-family:#{style["font-family"]};color:#{style["color"]};"
    end
    # if style["shadow"]
    #   str += "box-shadow: #{Math.sin(style["shadow"]["angle"] * style["shadow"]["distance"])}px #{Math.cos(style["shadow"]["angle"] * style["shadow"]["distance"])}px #{style["shadow"]["blur"]} rgba(#{style["shadow"]["color"]}, #{style["shadow"]["opacity"]/100});"
    # end
    if style['background-image']
      str += "background-image:url(#{convertImagePath(style["background-image"])});background-repeat:#{style["background-repeat"]};background-position:#{scale(style["background-position"][0])}px #{scale(style["background-position"][1])}px;background-size:#{scale(style["background-size"][0])}px #{scale(style["background-size"][1])}px;"
    end
    if style["top"]
      str += "top:#{scale(style["top"])}px;left:#{scale(style["left"])}px;z-index:#{@zIndex -= 1};"
    end
    if style["width"]
      str += "width:#{scale(style["width"])}px;height:#{scale(style["height"])}px;display:#{style["display"]};"
    end
    return str
  end
  def self.convert(node)
    @maxWidth = 320.0
    @maxHeight = 504.0
    nodeInfo = node
    className = node["attributes"]["class"]
    if node["attributes"]["anim"]
      parseAnim(node["attributes"]["anim"], className)
    end
    style = nodeInfo["attributes"]["style"]
    case node["nodeType"]
    when "root"
      if style["width"]
        @ratio = [(@maxWidth / style["width"]), (@maxHeight / style["height"]), 1].min
        Util.log("Compress image by ratio: #{@ratio}")
      end
      data = "<body style=\"#{stringifyStyle(style)}\">#{formatChild(node)}</body>"
      return data
    when "link"
      data = "<a href=\"#\" style=\"#{stringifyStyle(style)}\">#{formatChild(node)}</a>"
    when "container"
      data = "<div style=\"#{stringifyStyle(style)}\">#{formatChild(node)}</div>"
      
      # return formatChild(node)
    when "text"
        data = "<span style=\"#{stringifyStyle(style)}\" class=\"#{className}\">#{nodeInfo["children"]}</span>"
    when "image"
      data = "<img src=\"#{convertImagePath(nodeInfo["attributes"]["src"])}\" alt=\"\" style=\"#{stringifyStyle(style)}\" class=\"#{className}\"/>"
    end
    data
  end
  def self.render(convertor)
    @zIndex = 99999
    @extStyle = ''
    htmlString = format(convertor.getNodeInfo)
    @result = "<html><head><style>a, div,span,img{position:absolute;}#{@extStyle}</style></head>#{htmlString}</html>"
    return @result
  end
end