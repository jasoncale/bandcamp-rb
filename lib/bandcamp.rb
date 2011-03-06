require 'httparty'

module Bandcamp
  class Base
    include HTTParty
    format :json
    base_uri 'api.bandcamp.com/api'

    class << self
      attr_writer :api_key
      
      def api_key
        if @api_key.nil?
          raise 'NoAPIKeyGiven'
        else
          return @api_key
        end
      end
      
      def url(search)
        get("/url/1/info", :query => { :key => api_key, :url => search })        
      end
    end 
  end
  
  class Band < Base
    attr_reader :name, :url, :band_id, :subdomain, :offsite_url
    
    def initialize(band)      
      @name        = band['name']
      @url         = band['url']
      @band_id     = band['band_id']
      @subdomain   = band['subdomain']
      @offsite_url = band['offsite_url']
    end
    
    def discography
      response = self.class.get("/band/3/discography", :query => { :key => Bandcamp::Base.api_key, :band_id => band_id })
      return response['discography'] if response && response['discography'] 
    end
    
    class << self
      def find(name)
        response = get("/band/3/search", :query => { :key => Bandcamp::Base.api_key, :name => name })
        if response && response['results']
          response['results'].map { |band| new(band) } 
        else
          response
        end
      end
      
      def load(*band_ids)
        response = get("/band/3/info", :query => { :key => Bandcamp::Base.api_key, :band_id => band_ids.join(",") })
        if band_ids.length > 1
          band_ids.map { |band_id|
            new(response[band_id.to_s])
          }
        else
          new(response) if response
        end
      end
    end
  end
  
  class Album < Base
    attr_reader :title, :release_date, :downloadable, :url, :about, :credits,
                :small_art_url, :large_art_url, :artist, :album_id, :band_id, :tracks
    
    def initialize(album)      
      @title         = album['title']
      @release_date  = Time.at(album['release_date'])
      @downloadable  = album['downloadable']
      @url           = album['url']
      @about         = album['about']
      @credits       = album['credits']      
      @small_art_url = album['small_art_url']
      @large_art_url = album['large_art_url']
      @artist        = album['artist']
      @album_id      = album['album_id']
      @band_id       = album['band_id']
      @tracks        = album['tracks'].map{ |track| Track.new(track) }
    end
        
    def band
      @band ||= Band.load(band_id)
    end
    
    class << self
      def load(id)
        response = get("/album/2/info", :query => { :key => Bandcamp::Base.api_key, :album_id => id })
        new(response) if response
      end
    end
  end
  
  class Track < Base
    attr_reader :lyrics, :downloadable, :duration, :about, :album_id, :credits,
                :streaming_url, :number, :title, :url, :track_id, :band_id
    
    def initialize(track)
      @lyrics        = track['lyrics']
      @downloadable  = track['downloadable']
      @duration      = track['duration']
      @about         = track['about']
      @album_id      = track['album_id']
      @credits       = track['credits']
      @streaming_url = track['streaming_url']
      @number        = track['number']
      @title         = track['title']
      @url           = track['url']
      @track_id      = track['track_id']
      @band_id       = track['band_id']
    end
    
    def album
      @album ||= Album.load(album_id)
    end
    
    def band
      @band ||= Band.load(band_id)
    end
    
    class << self
      def load(id)
        response = get("/track/1/info", :query => { :key => Bandcamp::Base.api_key, :track_id => id })
        new(response) if response
      end
    end
  end
end