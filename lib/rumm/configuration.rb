require 'singleton'
require 'json'
require 'rbconfig'
require 'fog'

module Rumm

  class Configuration
    include Singleton

    def initialize
      @config = defaults
      reload
    end

    def [](key)
      @config["environments"]["default"][key.to_s] rescue nil
    end

    def []=(key, value)
      @config["environments"]["default"][key.to_s] = value
    end

    [:username, :api_key, :region].each do |sym|
       class_eval <<-META
       def self.#{sym}
         instance['#{sym}']
       end

       def self.#{sym}=(value)
         instance['#{sym}'] = value
       end

       META
    end

    def self.region
      ENV['REGION'] || instance['region']
    end

    def lon_region?
      !self[:region].nil? && self[:region].to_s.downcase == "lon"
    end

    def self.auth_endpoint
      # Note: You can authenticate against any endpoint regardless of the location of your cloud account, however, to locate the proper service endpoints
      # you must authenticate against the correct cloud endpoint
      instance.lon_region? ? Fog::Rackspace::UK_AUTH_ENDPOINT : Fog::Rackspace::US_AUTH_ENDPOINT
    end

    def reload
      return false unless File.exists? default_path

      begin
        File.open default_path do |f|
          h = JSON.load f
          @config.merge! h
          true
        end
      rescue => e
        fail "Unable to read #{default_path} - #{e.inspect}"
      end
    end

    def self.save
      instance.save
    end

    def save
      begin
        File.open default_path, 'w' do |f|
          JSON.dump @config, f
          true
        end
      rescue => e
        fail "Unable to write #{default_path} - #{e.inspect}"
      end
    end

    def self.delete
      instance.delete
    end

    def delete
      @config = defaults
      File.delete(default_path) if File.exists? default_path
      true
    rescue => e
      fail "Unable to delete #{default_path} - #{e.inspect}"
    end

    def default_path
      if windows? && !cygwin?
        File.join(ENV['USERPROFILE'].gsub("\\","/"), ".rumm")
      else
        File.join((ENV["HOME"] || "./"), ".rumm")
      end
    end

    private

    def defaults
      { "environments" => {
          "default" => {
            "region" => :ord
          }
        }
      }
    end

    # see http://stackoverflow.com/questions/4871309/what-is-the-correct-way-to-detect-if-ruby-is-running-on-windows
    def windows?
      RbConfig::CONFIG["host_os"] =~ /mswin|mingw|cygwin/
    end

    def cygwin?
      RbConfig::CONFIG["host_os"] =~ /cygwin/
    end

  end
end