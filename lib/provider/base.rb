class VideoInfo
	module Provider
		class Base
			class << self
				attr_accessor :provider_name
				attr_accessor :url_regex
			end

		  attr_accessor :video_id, :embed_url, :embed_code, :url, :provider, :title, :description, :keywords,
		                :duration, :date, :width, :height,
		                :thumbnail_small, :thumbnail_large,
		                :view_count,
		                :openURI_options

		  def self.matches?(url)
		    url =~ self.url_regex
		  end

		  def initialize(url, options = {})
		  	@provider = self.class.provider_name

		    @openURI_options = options

		    get_video_id(url)

		    get_info unless @video_id.nil? || @video_id.empty?
		  end

			private
				def get_video_id
					raise "Override #get_video_id"
				end
				
		  	def get_info
			  	raise "Override #get_info"
		  	end
		end
	end
end