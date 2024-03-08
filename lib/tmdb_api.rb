require 'toml-rb'
require_relative './tmdb_api_resource'

module Tmdb
  module API
    class Client
      attr_accessor :headers

      VERSION  = '3'
      BASE_URI = "http://api.themoviedb.org/#{VERSION}"

      JSON_HEADERS = {
          content_type: 'application/json; charset=utf-8',
          accept:       'application/json'
      }

      def initialize(account_id, access_token)
        @access_token = access_token
        @account_id = account_id
        @headers = JSON_HEADERS.merge('Authorization' => "Bearer #{@access_token}")
      end

      # Initialize based on config file provided
      def self.from_config(config_file = 'tmdb-config.toml')
        config = TomlRB.load_file(config_file)
        account_id = config['account_id']
        access_token = config['access_token']
        self.new(account_id, access_token)
      end

      def movie_favorites
        url = "#{base_url}/favorite/movies"
        Resource.new(self, url)
      end

      def tv_favorites
        url = "#{base_url}/favorite/tv"
        Resource.new(self, url)
      end

      def movie_watchlist
        url = "#{base_url}/watchlist/movies"
        Resource.new(self, url)
      end

      def tv_watchlist
        url = "#{base_url}/watchlist/tv"
        Resource.new(self, url)
      end

      def base_url
        "#{BASE_URI}/account/#{@account_id}"
      end
    end
  end
end

