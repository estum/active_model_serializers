module ActiveModel
  class Serializer
    module Configuration
      include ActiveSupport::Configurable
      extend ActiveSupport::Concern

      included do |base|
        base.config.array_serializer = ActiveModel::Serializer::ArraySerializer
        base.config.adapter = :flatten_json
        base.config.use_sideloading = false

        def self.configure
          super

          if config.use_sideloading
            autoload :SideloadedAssociations
            include SideloadedAssociations
          end
        end
      end
    end
  end
end
