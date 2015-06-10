module Psdparser
  module PsConvertor
    class Block < ::Psdparser::Convertor
      def after_init
        @nodeType = "container"
        @attributes["class"] = "block-#{guid}"
      end
    end
  end

end