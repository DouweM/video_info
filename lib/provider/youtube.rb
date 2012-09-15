require_relative 'base'

class VideoInfo
  module Provider
    class Youtube < Provider::Base
      self.provider_name = "YouTube"

      self.url_regex = /youtu(\.be)?(be\.com)?.*(?:\/|v=)([\w-]+)/

      private
        def get_video_id(url)
          url_matches = url.match(self.class.url_regex)
          @video_id = url_matches ? url_matches[3] : nil
        end

        def get_info
          begin
            doc = Hpricot(open("http://gdata.youtube.com/feeds/api/videos/#{@video_id}", @openURI_options))
            @url              = "http://www.youtube.com/watch?v=#{@video_id}"
            @embed_url        = "http://www.youtube.com/embed/#{@video_id}"
            @embed_code       = "<iframe src=\"#{@embed_url}\" frameborder=\"0\" allowfullscreen=\"allowfullscreen\"></iframe>"
            @title            = doc.search("media:title").inner_text
            @description      = doc.search("media:description").inner_text
            @keywords         = doc.search("media:keywords").inner_text
            @duration         = doc.search("yt:duration").first[:seconds].to_i
            @date             = Time.parse(doc.search("published").inner_text, Time.now.utc)
            @thumbnail_small  = doc.search("media:thumbnail").min { |a,b| a[:height].to_i * a[:width].to_i <=> b[:height].to_i * b[:width].to_i }[:url]
            @thumbnail_large  = doc.search("media:thumbnail").max { |a,b| a[:height].to_i * a[:width].to_i <=> b[:height].to_i * b[:width].to_i }[:url]
            # when your video still has no view, yt:statistics is not returned by Youtube
            # see: https://github.com/thibaudgg/video_info/issues#issue/2
            if doc.search("yt:statistics").first
              @view_count     = doc.search("yt:statistics").first[:viewcount].to_i
            else
              @view_count     = 0
            end
          rescue
            nil
          end
        end
    end
  end
end