require 'json'

module Tmdb

  class MediaNote

    GENRE_TAGS = {
      28 => 'Action',
      12 => 'Adventure',
      16 => 'Animation',
      35 => 'Comedy',
      80 => 'Crime',
      99 => 'Documentary',
      18 => 'Drama',
      10751 => 'Family',
      14 => 'Fantasy',
      36 => 'History',
      27 => 'Horror',
      10402 => 'Music',
      9648 => 'Mystery',
      10749 => 'Romance',
      878 => 'Science Fiction',
      10770 => 'TV Movie',
      53 => 'Thriller',
      10752 => 'War',
      37 => 'Western',
    }.map { |id, name|
        hashtag_name = "##{name.downcase.gsub(' ', '-')}"
          [id, hashtag_name]
    }.to_h

    attr_reader :id, :title, :release_date, :poster_path, :overview, :tags
  
    def initialize(data)
      @id = data["id"]
      @title = data["title"] || data["name"]  # Accommodate for TV show naming
      @release_date = data["release_date"] || data["first_air_date"]  # For TV shows
      @poster_path = data["poster_path"]
      @overview = data["overview"]
      @genres = data["genre_ids"].map { |id| GENRE_TAGS[id] }
    end

    def add_tag(tag)
      tags << tag
    end

    def filename
      nice_title = @title.gsub(':', ' -').gsub('?', '')
      return "#{nice_title}.md" if @release_date.empty?
      release_year = Date.parse(@release_date).year
      "#{nice_title} (#{release_year}).md"
    end
  
    def generate_markdown
      <<~MARKDOWN
        #{tmdb_url}
  
        #{(tags + @genres).join("\n")}
  
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
