require 'httparty'

module Bandcamp
  class Base
    include HTTParty
    format :json
    base_uri 'api.bandcamp.com/api'

    class << self; attr_accessor :api_key; end;    
  end
  
  class Band < Base
    attr_reader :name, :url, :band_id, :subdomain
    
    def initialize(band_id)
      raise 'NoAPIKeyGiven' if Bandcamp::Base.api_key.nil?
      response = self.class.get("/band/1/info", :query => { :key => Bandcamp::Base.api_key, :band_id => band_id })      
      
      @name = response['name']
      @url = response['url']
      @band_id = response['band_id']
      @subdomain = response['subdomain']
    end
    
    def discography
      self.class.get("/band/1/discography", :query => { :key => Bandcamp::Base.api_key, :band_id => band_id })['discography']
    end
  end
  
  class Album < Base
    attr_reader :title, :release_date, :downloadable, :url, :about, :credits,
                :small_art_url, :large_art_url, :artist, :album_id, :band_id
    
    def initialize(id)
      raise 'NoAPIKeyGiven' if Bandcamp::Base.api_key.nil?
      response = self.class.get("/album/1/info", :query => { :key => Bandcamp::Base.api_key, :album_id => id })
      
      @title = response['title']
      @release_date = Time.at(response['release_date'])
      @downloadable = response['downloadable']
      @url = response['url']
      @about = response['about']
      @credits = response['credits']      
      @small_art_url = response['small_art_url']
      @large_art_url = response['large_art_url']
      @artist = response['artist']
      @album_id = response['album_id']
      @band_id = response['band_id']
    end
    
    def tracks
      @tracks = []
    end
    
    def band
      @band ||= Band.new(band_id)
    end
  end
  
  class Track
  end
end