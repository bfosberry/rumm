require "rumm/configuration"
require "spec_helper"

describe "configuration" do

  describe "defaults" do
    before(:all) do
      ENV['HOME'] = nil
    end
    it "should be initialized with defaults" do
      Rumm::Configuration.region.should == :ord
      Rumm::Configuration.username.should == nil
      Rumm::Configuration.api_key.should == nil
    end
  end

  describe "Configuration file present" do
    before(:all) do
      @rumm_dir =  File.expand_path "#{File.dirname(__FILE__)}/../tmp"
      File.open("#{@rumm_dir}/.rumm", 'w') do |f|
        f.puts "{\"environments\":{\"default\":{\"region\":\"dfw\",\"username\":\"racker\",\"api_key\":\"1234\"}}}"
      end
      ENV['HOME'] = @rumm_dir
      Rumm::Configuration.instance.reload
    end
  
    after(:all) do
      File.delete "#{@rumm_dir}/.rumm" if File.exists? "#{@rumm_dir}/.rumm"
    end
    
    it "should be initialized with .rumm file if present" do
      Rumm::Configuration.region.should == "dfw"
      Rumm::Configuration.username.should == 'racker'
      Rumm::Configuration.api_key.should == '1234'
    end
    
    describe "region" do
      before { ENV['REGION'] = "SYD" }
      after { ENV['REGION'] = nil}
      it "should be overridable with REGION environment var" do
        Rumm::Configuration.region.should == "SYD"
      end
    end
    
    describe "lon_region?" do
      it "should return true if region is 'lon'" do
        Rumm::Configuration.region = 'lon'
        Rumm::Configuration.instance.lon_region?.should be_true
      end
      it "should return true if region is 'LON'" do
        Rumm::Configuration.region = 'LON'
        Rumm::Configuration.instance.lon_region?.should be_true
      end
      it "should return true if region is :lon" do
        Rumm::Configuration.region = :lon
        Rumm::Configuration.instance.lon_region?.should be_true
      end
      it "should return false if region is nil" do
        Rumm::Configuration.region = nil
        Rumm::Configuration.instance.lon_region?.should be_false
      end
      it "should return false if region is 'dfw'" do
        Rumm::Configuration.region = 'dfw'
        Rumm::Configuration.instance.lon_region?.should be_false
      end
    end
    
    describe "auth_endpoint" do
      it "should return UK authentication endpoint if region is lon" do
        Rumm::Configuration.region = :lon
        Rumm::Configuration.auth_endpoint.should == Fog::Rackspace::UK_AUTH_ENDPOINT
      end
      it "should return US authentication endpoint if region is syd" do
        Rumm::Configuration.region = :syd
        Rumm::Configuration.auth_endpoint.should == Fog::Rackspace::US_AUTH_ENDPOINT
      end
    end
    
    describe "reload" do
      after(:each) do 
        ENV['HOME'] = @rumm_dir
        Rumm::Configuration.instance.reload
      end
      
      it "should reload configuration if config file is present" do
        Rumm::Configuration.username = "unclebob"
        Rumm::Configuration.instance.reload.should be_true
        
        Rumm::Configuration.username.should == "racker"
      end
      it "should not reload values if configuration file does not exist" do
        ENV['HOME'] = nil
        Rumm::Configuration.username = "unclebob"
        Rumm::Configuration.instance.reload.should be_false
        
        Rumm::Configuration.username.should == "unclebob"
      end
    end
    
    describe "delete" do
      it "should delete file if it exists and revert to default configuration" do
        File.expects(:delete)
        Rumm::Configuration.delete

        Rumm::Configuration.region.should == :ord
        Rumm::Configuration.username.should == nil
        Rumm::Configuration.api_key.should == nil
      end
      it "should not delete file if it does not exist" do
        File.expects(:exists?).with("#{@rumm_dir}/.rumm").returns(false)
        File.expects(:delete).never

        Rumm::Configuration.delete.should be_true
        
        Rumm::Configuration.region.should == :ord
        Rumm::Configuration.username.should == nil
        Rumm::Configuration.api_key.should == nil
      end
    end
    
    describe "save" do
      it "should save the configuration" do
        JSON.expects(:dump)
        
        Rumm::Configuration.save.should be_true
      end
    end
      
  end
end