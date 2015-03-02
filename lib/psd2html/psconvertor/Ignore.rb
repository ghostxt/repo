module Psd2html
	module PsConvertor
  	class Ignore < ::Psd2html::Convertor
      def skip
        true
      end
  	end
  end

end