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

  def self.apple_id_from_app_store_link(app_store_link)
    start_token = "/id"
    end_token = "?"
    return app_store_link[/#{start_token}(.*?)#{end_token}/m, 1]
  end

  def self.app_hash_from_itunes_metadata(itunes_metadata)
    return nil if itunes_metadata.nil?
    app = {}
    app['apple_id'] = itunes_metadata['trackId']
    app['name'] = itunes_metadata['trackName']
    app['app_store_link'] = itunes_metadata['trackViewUrl']
    app['iphone_screenshots'] = itunes_metadata['screenshotUrls']
    app['ipad_screenshots'] = itunes_metadata['ipadScreenshotUrls']
    app['icon_image_link'] = itunes_metadata['artworkUrl512']
    app['icon_image_link_100'] = itunes_metadata['artworkUrl100']
    return app
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


    def search_appfigures_using_search_term(term)
      results = @appfigures.products_search(URI.escape(term))
      results.each do |result|
        percentage_difference = self.string_difference_percent(result['name'], app_name)
        result['priority'] = percentage_difference
      end

      results = results.sort_by { |k, v| k['priority']  }
      results.each do |result|
        puts "Found result with name: %s" % result['name']

        itunes_lookup = self.itunes_lookup(result['refno'])
        if not itunes_lookup.nil?
          if itunes_lookup['bundleId'] == options[:bundle_id]
            puts "Found app: %s" % result['name']
            itunes_metadata = itunes_lookup
            appfigures_metadata = result
            return itunes_metadata, appfigures_metadata
          end
        end
      end

      return nil, nil

    end

    def search_with_app_store_link(app_store_link)
      apple_id = Appstorelookup.apple_id_from_app_store_link(app_store_link)
      return nil if not apple_id
      itunes_metadata = self.itunes_lookup(apple_id)
      return Appstorelookup.app_hash_from_itunes_metadata(itunes_metadata)
    end


    def search(options)

      bundle_id_parts = options[:bundle_id].split(".")
      app_name = bundle_id_parts[bundle_id_parts.length-1]
      reverse_domain = bundle_id_parts[0, bundle_id_parts.length-1].join(".")
      company_name = (options[:company_name] if options[:company_name]) || (bundle_id_parts[1])
      app_name = options[:display_name] if options[:display_name]

      terms = [app_name + "+" + company_name, app_name, company_name]

      catch (:done) do
        terms.each do |term|
          itunes_metadata, appfigures_metadata = self.search_appfigures_using_search_term(term)
          throw :done if itunes_metadata
        end
      end

      return nil if (itunes_metadata.nil? or not defined? itunes_metadata)

      app = Appstorelookup.app_hash_from_itunes_metadata(itunes_metadata)
      app['sku'] = appfigures_metadata['sku']

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