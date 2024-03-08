require 'json'

module Tmdb

  class MediaNote

    attr_reader :id, :title, :release_date, :poster_path, :overview, :tags
  
    def initialize(data)
      @id = data["id"]
      @title = data["title"] || data["name"]  # Accommodate for TV show naming
      @release_date = data["release_date"] || data["first_air_date"]  # For TV shows
      @poster_path = data["poster_path"]
      @overview = data["overview"]
    end

    def add_tag(tag)
      tags << tag
    end

    def filename
      "#{@title} (#{@release_date}).md"
    end
  
    def generate_markdown
      <<~MARKDOWN
        #{tmdb_url}
  
        #{tags.join("\n")}
  
        ![](https://image.tmdb.org/t/p/w185#{@poster_path})
  
        #{@overview}
      MARKDOWN
    end
  
    # This method will be overridden in subclasses to provide the correct URL
    def tmdb_url
      raise NotImplementedError, 'This method should be overridden in a subclass'
    end
  end
  
  class MovieNote < MediaNote
    def initialize(json_data)
      super(json_data)
      @tags = ['#Movie', '#tmdb']
    end
  
    def tmdb_url
      "https://www.themoviedb.org/movie/#{@id}"
    end
  end
  
  class TvShowNote < MediaNote
    def initialize(json_data)
      super(json_data)
      @tags = ['#TVShow', '#tmdb']
    end
  
    def tmdb_url
      "https://www.themoviedb.org/tv/#{@id}"
    end
  end
end
