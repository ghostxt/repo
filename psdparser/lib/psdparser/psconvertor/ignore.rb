module Psdparser
	module PsConvertor
  	class Ignore < ::Psdparser::Convertor
      def after_init
        @skip = true
      end
  	end
  end
end