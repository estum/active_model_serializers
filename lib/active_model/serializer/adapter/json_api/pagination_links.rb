module ActiveModel
  class Serializer
    class Adapter
      class JsonApi < Adapter
        class PaginationLinks
          FIRST_PAGE = 1

          attr_reader :collection, :context

          def initialize(collection, context)
            @collection = collection
            @context = context
          end

          def serializable_hash(options = {})
            pages_from.each_with_object({}) do |(key, value), hash|
              params = query_parameters.merge(page: value, per_page: collection.per_page).to_query

              hash[key] = "#{url(options)}?#{params}"
            end
          end

          private

          def pages_from
            return {} if collection.first_page? && collection.last_page?

            {}.tap do |pages|
              pages[:self] = collection.current_page

              unless collection.first_page?
                pages[:first] = FIRST_PAGE
                pages[:prev]  = collection.prev_page
              end

              unless collection.last_page?
                pages[:next] = collection.next_page
                pages[:last] = collection.total_pages
              end
            end
          end

          def url(options)
            @url ||= options.fetch(:links, {}).fetch(:self, nil) || original_url
          end

          def original_url
            @original_url ||= context.original_url[/\A[^?]+/]
          end

          def query_parameters
            @query_parameters ||= context.query_parameters
          end
        end
      end
    end
  end
end
