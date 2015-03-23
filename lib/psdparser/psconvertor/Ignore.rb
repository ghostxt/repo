module Psdparser
	module PsConvertor
  	class Ignore < ::Psdparser::Convertor
      def afterInit
        @skip = true
      end
  	end
  end

end