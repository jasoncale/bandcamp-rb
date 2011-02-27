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
      stub_json_request("http://api.bandcamp.com/api/band/1/info?band_id=3463798201&key=SECRET_API_KEY", "band")
      
      Bandcamp::Base.api_key = 'SECRET_API_KEY'
      @band = Bandcamp::Band.new('3463798201')
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
  
    context "discography" do
      setup do
        stub_json_request("http://api.bandcamp.com/api/band/1/discography?band_id=3463798201&key=SECRET_API_KEY", "band_discography")
        
        @discography = @band.discography
      end

      should "return all albums" do
        assert_equal(11, @discography.length)
      end
    end
  end
  
  context "An album" do
    setup do
      stub_json_request("http://api.bandcamp.com/api/album/1/info?album_id=2587417518&key=SECRET_API_KEY", "album")
        
      Bandcamp::Base.api_key = 'SECRET_API_KEY'
      @album = Bandcamp::Album.new("2587417518")
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
      stub_json_request("http://api.bandcamp.com/api/band/1/info?band_id=3463798201&key=SECRET_API_KEY", "band")
      
      assert_equal("Amanda Palmer", @album.band.name)
    end

    # These methods aren't covered in the sample API calls Bandcamp provide .. 
    # http://bandcamptech.wordpress.com/2010/05/15/bandcamp-api/
    
    # However they are mentioned in the API documentation so I've added extra data to the sample json files
    # so they can be tested for coverage ..
    
    should "have any specific artist information" do
      assert_equal("John Finn", @album.artist)      
    end
    
    should "have a downloadable id" do
      assert_equal(1, @album.downloadable)
    end
    
    should "have a url" do
      assert_equal("http://example.album.url", @album.url)
    end
  end
  
end