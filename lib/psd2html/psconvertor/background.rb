module Psd2html
  module PsConvertor
    class Background < ::Psd2html::Convertor
      def css_map
        imgUrl = "#{File.dirname(@dstPath)}/#{guid}.png"
        @psNode.image.save_as_png(imgUrl)
        parentConvertorClassName = @parentConvertor.get_classname
        @@html_dictory[parentConvertorClassName] = {"style" => ";background:url(#{guid}.png) center center"}
      end
      def html_skeleton
        return nil
      end
      def get_html_tpl
        return ""
      end 
    end
  end
end