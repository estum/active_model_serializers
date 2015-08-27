module ActiveModel
  class Serializer
    # Filters a list of relations will be included in a compound document
    # keeps only sideloaded associations. It prevents serializers
    # from making N+1 queries and referencing unrequested data.
    module SideloadedAssociations
      extend ActiveSupport::Concern

      module ClassMethods
        private

        def define_association_accessor(reflection)
          super

          define_method "#{reflection.name}_with_sideloading" do
            return unless association_preloaded?(reflection)
            public_send(:"#{reflection.name}_without_sideloading")
          end

          alias_method_chain reflection.name, :sideloading
        end
      end

      protected

      def serializer_reflections
        super.select { |reflection| association_preloaded?(reflection) }
      end

      # Checks a relationship to be preloaded.
      # @param [ActiveModel::Serializer::Reflection] reflection
      # @return [boolean]
      #
      # @api protected
      #
      def association_preloaded?(reflection)
        object.association_cache.include?(reflection.name.to_sym)
      end
    end
  end
end
