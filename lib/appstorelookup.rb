require 'thor'
require 'rubygems'
require 'appfigures'
require 'net/https'
require 'json'
require 'uri'


module Appstorelookup
  class CLI < Thor
    
		desc "search ", "Searches for a given app based on app display name, bundleId, "
	  method_option :bundle_id, :desc => "The applications bundle identifier"
	  method_option :display_name, :desc => "The app's display name"
	  method_option :company_name, :desc => "The company name of the company that created the app"
	  method_option :artist_id, :desc => "The app store identifier of the company that created the app"
	  method_option :apple_id, :desc => "The app's appleId"
	  method_option :verbose, :aliases => "-v", :desc => "Be verbose"
	  def search()
	    puts "\n"
	    appstorelookup = Appstorelookup.new options
	    sales = appstorelookup.search(options)
	    
# 	    tp sales, :index, {:name => {:width => 100}}, :downloads, :revenue, :revenue_per_download, :purchases_per_download
	  end

  end

  class Appstorelookup
    # @todo: make caching optional
  
    def initialize(options = {})
	    if options[:username] and options[:password]
	      @appfigures = Appfigures.new( {:username => options[:username], :password => options[:password]})
	    elsif ENV['APPFIGURES_USERNAME'] and ENV['APPFIGURES_PASSWORD']
	      @appfigures = Appfigures.new( {:username => ENV['APPFIGURES_USERNAME'], :password => ENV['APPFIGURES_PASSWORD']})
	    else
	      puts "ERROR: appfigures username/password not provides (-u name@example.com -p password)"
	    end
    
    end
    
    def string_difference_percent(a, b)
      longer = [a.size, b.size].max
      same = a.each_char.zip(b.each_char).select { |a,b| a == b }.size
      (longer - same) / a.size.to_f
    end
    
    
    def search(options)

      bundle_id_parts = options[:bundle_id].split(".")
      app_name = bundle_id_parts[bundle_id_parts.length-1]
      reverse_domain = bundle_id_parts[0, bundle_id_parts.length-1].join(".")
      company_name = bundle_id_parts[1]
      
      if options[:company_name]
        company_name = options[:company_name]
      end
      if options[:display_name]
        app_name = options[:display_name]
      end
      
      puts "app_name: %s" % app_name
      puts "reverse_domain: %s" % reverse_domain
      puts "company_name: %s" % company_name
      
      
      terms = [app_name + "+" + company_name, app_name, company_name]
      
      app_metadata_hash = nil
      itunes_metadata = nil
      appfigures_metadata = nil
      
      catch (:done) do
        terms.each do |term|
  
          results = @appfigures.products_search(URI.escape(term))
          results.each do |result|
            percentage_difference = self.string_difference_percent(result['name'], app_name)
            result['priority'] = percentage_difference
            
          end
          
          results = results.sort_by { |k, v| k['priority']  }
          
          results.each do |result|
            puts result['name']
            puts result['priority']
            puts "looking up item with reference number: %s" % result['refno']
            
            itunes_lookup = self.itunes_lookup(result['refno'])
            if not itunes_lookup.nil?
              if itunes_lookup['bundleId'] == options[:bundle_id]
                puts "Found app: %s" % result['name']
                itunes_metadata = itunes_lookup
                appfigures_metadata = result
                throw :done
              end
            end
          end
        end
      end
      
      app = nil
      puts "Done"
      if itunes_metadata
        app = {}
        puts "Found my stuff"
        app['apple_id'] = itunes_metadata['trackId']
        app['app_store_link'] = itunes_metadata['trackViewUrl']
        app['iphone_screenshots'] = itunes_metadata['screenshotUrls']
        app['ipad_screenshots'] = itunes_metadata['ipadScreenshotUrls']
        app['icon_image_link'] = itunes_metadata['artworkUrl512']
        app['sku'] = appfigures_metadata['sku']
      end
      
      return app
    end
    
    
    def itunes_lookup(apple_id)
      
    
      url = "https://itunes.apple.com/lookup?id=%s" % apple_id
			uri = URI.parse(url[0..-2])
			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = true
			
			request = Net::HTTP::Get.new(url)
					
			response = http.request(request)
			data = response.body
			results = JSON.parse(data)
			
			
			return results['results'][0]
    end
    
    
      
  
  end
  
end