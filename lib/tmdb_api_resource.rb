require 'rest-client'
require_relative 'utils'

module Tmdb
  module API
    class Resource

      include Utils

      def initialize(api_client, url)
        @api_client = api_client
        @url = url
      end

      # Get all pages of results
      def get_all
        next_page = 1
        total_pages = -1
        results = []

        until next_page == total_pages + 1
          response = get(@url, { page: next_page })
          next_page = response['page'].to_i + 1
          total_pages = response['total_pages']
          results.concat(response['results'])
        end

        results
      end

      def get(url, request_params = {})
        begin
          response = RestClient.get(url, @api_client.headers.merge(params: request_params))

        rescue => e
          parsed_exception_rs = parse_json(e.response)

          if parsed_exception_rs['status_message'].present?
            raise Tmdb::Error, parsed_exception_rs['status_message']
          else
            raise Tmdb::Error, e.response
          end
        end

        parse_json(response)
      end
    end
  end
end

