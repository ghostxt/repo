class Util

  
  def self.log(info, logPath = nil)
    if logPath
      STDOUT.puts "log:" + green(info) + " , save to:" + logPath
      File.open(logPath, "a")  do  |file| 
        file.puts("#{Time.new} #{info}")
      end
    else
      STDOUT.puts "log:" + green(info)
    end
  end

  def self.error(info)
    STDOUT.puts "error:" + red(info)
  end

  protected
  def self.colorize(color_code,str)
    "\e[#{color_code}m#{str}\e[0m"
  end

  def self.red(str)
    colorize(31,str)
  end

  def self.green(str)
    colorize(32,str)
  end

  def self.yellow(str)
    colorize(33,str)
  end

  def self.pink(str)
    colorize(35)
  end
  
  def self.connect_nodes(parent, child)
    child.parentConvertor = parent
    parent.childrenConvertors << child
  end
  
  def self.remove_last_modifier(name)
    node_name_arr = name.split('|')
    node_name_arr.pop
    node_name_arr.join('|')
  end
  
  def self.hash_to_array(originHash)
    dstArray = []
    originHash.each do |key,value| 
      dstArray << {"key"=>key,"value"=>value}
    end
    dstArray
  end 

  def self.parseEffects(psNode)
    effects = {}
    if psNode[:adjustments][:object_effects]
      objectEffects = psNode[:adjustments][:object_effects].data
      if objectEffects["DrSh"]
        shadow = objectEffects["DrSh"]
        effects["shadow"] = {
          "distance" => shadow["Dstn"][:value],
          "angle" => shadow["lagl"][:value],
          "blur" => shadow["blur"][:value],
          "color" => [shadow["Clr "]["Rd  "], shadow["Clr "]["Grn "], shadow["Clr "]["Bl  "]],
          "opacity" => shadow["Opct"][:value]
        }
      end
    end
    effects
  end
  
  def self.getConvertorName(node,nodeName = nil)
    type = node.to_hash[:type]
    name = nodeName || node.name
    if name.include?("|")
      convertorName = name.split('|').last.to_s
    elsif type == :group 
      convertorName = "block"
    elsif type == :layer && !node.text.nil?
      convertorName = "text"
    else
      convertorName = "img"
    end
    return convertorName
  end
  
  def self.css_hook(style)
    hookHash = {
      "pt" => "px",
      "MicrosoftYaHei" => "microsoft yahei"
      # "rgba\\((\\s*\\d+,\\s*\\d+,\\s*\\d+),\\s*\\d+\\)" => -> { '#' + $1.split(',').map { |v| v.to_i.to_s(16) }.join }
    }
    hookHash.each do |key,value|
      if value.is_a?(Proc)
        style = style.gsub(Regexp.new(key)) { value.call }
      else
        style = style.gsub(Regexp.new(key), value)
      end
    end
    style
  end
end