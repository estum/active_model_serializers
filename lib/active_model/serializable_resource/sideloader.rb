module ActiveModel
  class SerializableResource
    class Sideloader
      # Eager loads associations passed to a serializer with the +include+ options.
      #
      # == Parameters
      # +:resource+ is an ActiveRecord::Relation or a flatten array of records.
      # +:associations+ is a flatten array of association names or a string with
      #   names separated by commas. This parameter is a delegated +include+
      #   option passed to an adapter. Nested associations could be specified
      #   with dots, like "comments.author".
      #   It will be automaticaly converted to use with the +includes+ method.
      def sideload(resource, associations)
        if associations.present?
          associations = associations.is_a?(String) ? associations.split(",") : associations.dup

          associations.map! do |association|
            association.include?('.') ? build_nested_hash(association) : association
          end

          if resource.respond_to?(:includes)
            resource = resource.includes(*associations)
          else
            try_preload_on(resource, associations)
          end
        end

        resource
      end

      def try_preload_on(records, associations)
        if records.present?
          preloader = ActiveRecord::Associations::Preloader.new
          associations.each { |association| preloader.preload(records, association) }
        end

        records
      end

      # Builds a nested hash from a given string.
      #
      #   build_nested_hash("posts.comments.author")
      #   # => { "posts" => { "comments" => "author" } }
      def build_nested_hash(association)
        association.split('.').reverse_each.reduce do |nested_child, parent|
          { parent => nested_child }
        end
      end
    end
  end
end
