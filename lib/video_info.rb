require 'open-uri'
require 'hpricot'
require 'video_info/version'
require 'provider/vimeo'
require 'provider/youtube'

class VideoInfo
  PROVIDERS = [
    Provider::Vimeo,
    Provider::Youtube
  ]

  def self.provider_for_url(url)
    PROVIDERS.each do |provider|
      return provider if provider.matches?(url)
    end
    nil
  end

  def initialize(url, options = {})
    options = { "User-Agent" => "VideoInfo/#{VideoInfoVersion::VERSION}" }.merge options
    options.dup.each do |key,value|
      unless OpenURI::Options.keys.include? key
        if key.is_a? Symbol
          options[key.to_s.split(/[^a-z]/i).map(&:capitalize).join('-')] = value
          options.delete key
        end
      end
    end
    
    provider = self.class.provider_for_url(url)
    @video = provider ? provider.new(url, options) : nil
  end

  def valid?
    @video != nil && !["", nil].include?(@video.title)
  end

  def method_missing(sym, *args, &block)
    @video.send sym, *args, &block
  end
end