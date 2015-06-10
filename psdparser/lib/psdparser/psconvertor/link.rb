module Psdparser
  module PsConvertor
    class NewName
      def initialize(name)
        @name = name
      end
      def data
        @name
      end
    end
    class Link < ::Psdparser::Convertor
      def after_init
        @nodeType = "link"
        @attributes["class"] = "link-#{guid}"
        tmp_node = @psNode.clone
        name_str = Util.remove_last_modifier(psNode.name)
        name = NewName.new(name_str)
        tmp_node.adjustments[:name] = name
        p name
        self.psNode.children = [tmp_node]
        # Util.connect_nodes(@parentConvertor, self)
      end
      def guid
        "link-" + super
      end
    end
  end
end
