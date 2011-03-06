require "rubygems"
require 'test/unit'
require 'shoulda'
require 'webmock/test_unit'

require File.dirname(__FILE__) + '/../lib/bandcamp.rb'

def stub_json_request(url, json_file)
  stub_request(:get, url).to_return(
    {
      :body => File.read(File.dirname(__FILE__) + "/fixtures/#{json_file}.json"),
      :headers => { "Content-Type" => "text/json" }
    }
  )
end

class BandTest < Test::Unit::TestCase
  
  context "A band" do
    setup do      
      stub_json_request("http://api.bandcamp.com/api/band/3/info?band_id=3463798201&key=SECRET_API_KEY", "band")
      
      Bandcamp::Base.api_key = 'SECRET_API_KEY'
      @band = Bandcamp::Band.load('3463798201')
    end

    should "have a name" do
      assert_equal("Amanda Palmer", @band.name)
    end

    should "have a bandcamp url" do
      assert_equal("http://music.amandapalmer.net", @band.url)
    end

    should "have a band_id" do
      assert_equal(3463798201, @band.band_id)
    end

    should "have a subdomain" do
      assert_equal("amandapalmer", @band.subdomain)
    end
    
    should "have an offsite url" do
      assert_equal("http://www.amandapalmer.net", @band.offsite_url)
    end
  end
  
  context "A band discography" do
    setup do
      stub_json_request("http://api.bandcamp.com/api/band/3/info?band_id=203035041&key=SECRET_API_KEY", "sufjanstevens")
      stub_json_request("http://api.bandcamp.com/api/band/3/discography?band_id=203035041&key=SECRET_API_KEY", "band_discography")
      
      Bandcamp::Base.api_key = 'SECRET_API_KEY'
      @band = Bandcamp::Band.load('203035041')
      @discography = @band.discography
    end

    should "return all albums" do
      assert_equal(9, @discography.length)
    end
  end
  
  context "An album" do
    setup do
      stub_json_request("http://api.bandcamp.com/api/album/2/info?album_id=2587417518&key=SECRET_API_KEY", "album")
        
      Bandcamp::Base.api_key = 'SECRET_API_KEY'
      @album = Bandcamp::Album.load("2587417518")
    end
    
    should "have a title" do
      assert_equal("Who Killed Amanda Palmer", @album.title)
    end
    
    should "have a release date" do
      assert_equal("Tue Sep 16 01:00:00 +0100 2008", @album.release_date.to_s)
    end
    
    should "have a description (about)" do
      assert_equal("For additional information including a recording-diary by Amanda, exclusive videos, liner notes, lyrics, and much more, please visit http://www.whokilledamandapalmer.com", @album.about)
    end
    
    should "have credits" do
      assert_equal("For a complete list of credits, please visit http://www.whokilledamandapalmer.com/credits.php", @album.credits)
    end
    
    should "have url to small version of artwork" do
      assert_equal("http://bandcamp.com/files/33/09/3309055932-1.jpg", @album.small_art_url)
    end
    
    should "have url to large version of artwork" do
      assert_equal("http://bandcamp.com/files/41/81/41814958-1.jpg", @album.large_art_url)      
    end
    
    should "set an album id" do
      assert_equal(2587417518, @album.album_id)
    end
    
    should "have a band" do
      stub_json_request("http://api.bandcamp.com/api/band/3/info?band_id=3463798201&key=SECRET_API_KEY", "band")      
      assert_equal("Amanda Palmer", @album.band.name)
    end
    
    should "have any specific artist information" do
      # this has been added to the fixture as the response from
      # band camp doesn't include this information...
      assert_equal("John Finn", @album.artist)      
    end
    
    should "have a downloadable id" do
      assert_equal(2, @album.downloadable)
    end
    
    should "have a url" do
      assert_equal("http://music.amandapalmer.net/album/who-killed-amanda-palmer", @album.url)
    end
  end
  
  context "A track" do
    setup do
      stub_json_request("http://api.bandcamp.com/api/track/1/info?track_id=1269403107&key=SECRET_API_KEY", "track")
      Bandcamp::Base.api_key = 'SECRET_API_KEY'
      
      @track = Bandcamp::Track.load("1269403107")
    end
  
    should "have a duration" do
      assert_equal(317.378, @track.duration)
    end
    
    should "have lyrics" do
      assert_match(/When you were here before/, @track.lyrics)
    end
    
    should "have an album" do
      stub_json_request("http://api.bandcamp.com/api/album/2/info?album_id=1003295408&key=SECRET_API_KEY", "album")
      assert_equal(1003295408, @track.album_id)
      assert_equal("Who Killed Amanda Palmer", @track.album.title)
    end
    
    should "have downloadable flag" do
      assert_equal(2, @track.downloadable)
    end
    
    should "have about" do
      assert_match(/Recorded live in Prague/, @track.about)
    end
    
    should "have track number" do
      assert_equal(7, @track.number)
    end
    
    should "have credits" do
      assert_match(/Featuring: Amanda Palmer/, @track.credits)
    end
    
    should "have a title" do
      assert_equal("Creep (Live in Prague)", @track.title)
    end
    
    should "have streaming url" do
      assert_equal("http://popplers5.bandcamp.com/download/track?enc=mp3-128&id=1269403107&stream=1&ts=1298800847.0&tsig=67543bb7f276035915039c5545744d3b", @track.streaming_url)
    end
    
    should "have track id" do
      assert_equal(1269403107, @track.track_id)
    end
    
    should "have a url" do
      assert_equal("/track/creep-live-in-prague", @track.url)
    end
    
    should "have a band" do
      assert_equal(3463798201, @track.band_id)
      stub_json_request("http://api.bandcamp.com/api/band/3/info?band_id=3463798201&key=SECRET_API_KEY", "band")      
      assert_equal("Amanda Palmer", @track.band.name)
    end
  end
   
  context "searching" do
    setup do
      stub_json_request("http://api.bandcamp.com/api/band/3/search?key=SECRET_API_KEY&name=baron%20von%20luxxury", "search")
      Bandcamp::Base.api_key = 'SECRET_API_KEY'
      
      @bands = Bandcamp::Band.find('baron von luxxury')
    end
  
    should "return two bands" do
      assert_equal(2, @bands.length)
    end
    
    should "parse the bands correctly" do
      assert_equal(1366501350, @bands[0].band_id)
    end
  end
  
  context "multiple bands" do
    setup do
      stub_json_request("http://api.bandcamp.com/api/band/3/info?key=SECRET_API_KEY&band_id=4214473200,3789714150", "multiple_bands")
      Bandcamp::Base.api_key = 'SECRET_API_KEY'
      
      @bands = Bandcamp::Band.load('4214473200', '3789714150')
    end
  
    should "return two bands" do
      assert_equal(2, @bands.length)
    end
    
    should "parse the bands correctly" do
      assert_equal(4214473200, @bands[0].band_id)
      assert_equal(3789714150, @bands[1].band_id)
    end
  end
  
  context "url search" do
    setup do
      stub_json_request("http://api.bandcamp.com/api/url/1/info?key=SECRET_API_KEY&url=http://music.sufjan.com/track/enchanting-ghost", "url_search")
      Bandcamp::Base.api_key = 'SECRET_API_KEY'
      @results = Bandcamp::Base.url('http://music.sufjan.com/track/enchanting-ghost')
    end

    should "return results" do
      assert_equal(2323108455, @results['track_id'])
      assert_equal(203035041, @results['band_id'])
    end
  end
  
  
end