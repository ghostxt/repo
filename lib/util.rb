class Util

  
  def self.log(info)
    STDOUT.puts "log:" + green(info)
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