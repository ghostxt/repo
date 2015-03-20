module Psdparser
	module PsConvertor
  	class Ignore < ::Psdparser::Convertor
      def skip
        true
      end
  	end
  end

end