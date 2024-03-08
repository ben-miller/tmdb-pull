require 'toml-rb'
require_relative './tmdb_api'
require_relative './tmdb_note'

module Tmdb

  class PullToNotes
    def initialize(api_client, movie_dir, tv_dir)
      @api_client = api_client
      @movie_dir = movie_dir
      @tv_dir = tv_dir
    end

    def self.from_config(config_file = 'tmdb-config.toml')
      config = TomlRB.load_file(config_file)

      # Init API client
      account_id = config['account_id']
      access_token = config['access_token']
      api_client = Tmdb::API::Client.new(account_id, access_token)

      # Get out dirs
      movie_dir = config['movie_dir']
      tv_dir = config['tv_dir']

      self.new(api_client, movie_dir, tv_dir)
    end

    def run

      # Initial checks
      check_dir(@movie_dir)
      check_dir(@tv_dir)

      # Get faves, watchlist
      movie_faves = @api_client.movie_favorites.get_all
      movie_watchlist = @api_client.movie_watchlist.get_all
      tv_faves = @api_client.tv_favorites.get_all
      tv_watchlist = @api_client.tv_watchlist.get_all

      # Write notes to disk
      write_media_notes(movie_faves, movie_watchlist, @movie_dir, Tmdb::MovieNote)
      write_media_notes(tv_faves, tv_watchlist, @tv_dir, Tmdb::TvShowNote)

    end

    private

    def check_dir(dir)
      unless File.directory?(dir)
        raise "Directory #{dir} does not exist"
      end
    end

    def write_media_notes(faves, watchlist, dir, note_class)
      # Create a hash of movie notes, adding "liked" tag to each
      notes = faves.each_with_object({}) do |media,hash|
        hash.fetch(media['id']) { hash[media['id']] = note_class.new(media) }
        hash.fetch(media['id']).add_tag('#liked')
      end

      # Add watchlist items, each w/ "watchlist" tag
      watchlist.each do |media|
        notes.fetch(media['id']) { notes[media['id']] = note_class.new(media) }
        notes.fetch(media['id']).add_tag('#watchlist')
      end

      notes.values.each do |note|
        note_file = File.join(dir, note.filename)
        File.open(note_file, "w") do |f|
          f.write(note.generate_markdown)
        end
      end
    end

  end

end

