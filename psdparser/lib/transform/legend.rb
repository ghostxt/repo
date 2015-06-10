class OutputFormat  
  attr_accessor :result, :maxWidth, :maxHeight, :ratio, :root, :zIndex
  def self.formatChild(node)
    if node[:children] && node[:children].length > 0
      style = node["attributes"]["style"];
      node[:children].each_with_index do |child,index|
        if style["left"] && style["top"]
          child["attributes"]["style"]["left"] +=  style["left"]
          child["attributes"]["style"]["top"] +=  style["top"]
        end
        format(child)
      end
    end
  end
  def self.format(node)
    node["nodeType"]
    data = convert(node)
    return data
  end
  def self.scale(num)
    return (num.to_i * @ratio).round
  end
  def self.convert(node)
    @maxWidth = 320.0
    @maxHeight = 504.0
    nodeInfo = node
    style = nodeInfo["attributes"]["style"]
    case node["nodeType"]
    when "root"
      if style["width"]
        @ratio = [(@maxWidth / style["width"]), (@maxHeight / style["height"]), 1].min
        Util.log("Compress image by ratio: #{@ratio}")
      end
      data = {
        "thumbnailUrl" => nodeInfo["attributes"]["thumbnail"],
        "components" => []
      }
      @root = data
      formatChild(node)
      return data
    when "container"
      formatChild(node)
      # data = {
      #   "type" => "container",
      #   "surface" => {
      #     "x" => scale(style["left"]),
      #     "y" => scale(style["left"]),
      #     "width" => scale(style["width"]),
      #     "height" => scale(style["height"]),
      #     "z-index" => style["z-index"],
      #     "rotate" => 0,
      #     "opacity" => 1
      #   },
      #   "attributes" => {},
      #   "components" => []
      # }
    when "text"
      data = {
        "type" => "label",
        "surface" => {
          "x" => scale(style["left"]),
          "y" => scale(style["top"]),
          "width" => scale(style["width"]),
          "height" => scale(style["height"]),
          "z-index" => (@zIndex -= 1),
          "rotate" => 0,
          "opacity" => 1
        },
        "attributes" => {
          "html" => "<span style=\"font-size:#{style["font-size"]};font-family:#{style["font-family"]};color:#{style["color"]};\">#{nodeInfo["children"]}</span>"
        }
      }
      @root["components"].unshift(data)
    when "image"
      data = {
        "type" => "image",
        "surface" => {
          "x" => scale(style["left"]),
          "y" => scale(style["top"]),
          "width" => scale(style["width"]),
          "height" => scale(style["height"]),
          "z-index" => (@zIndex -= 1),
          "rotate" => 0,
          "opacity" => 1
        },
        "attributes" => {
          "src" => nodeInfo["attributes"]["src"]
        }
      }
      @root["components"].unshift(data)
    end
    data
  end
  def self.render(convertor)
    @zIndex = 9999
    @result = format(convertor.getNodeInfo)
    return @result.to_json
  end
end