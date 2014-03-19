module Ahoy
  module Model

    def ahoy_visit
      class_eval do

        belongs_to :user, polymorphic: true

        before_create :set_traffic_source
        before_create :set_utm_parameters
        before_create :set_technology
        before_create :set_location

        def set_traffic_source
          referring_uri = Addressable::URI.parse(referrer) rescue nil
          self.referring_domain = referring_uri.try(:host)
          search_keyword = RefererParser::Referer.new(referrer).search_term rescue nil
          self.search_keyword = search_keyword.present? ? search_keyword : nil
        end

        def set_utm_parameters
          landing_uri = Addressable::URI.parse(landing_page) rescue nil
          if landing_uri
            query_values = landing_uri.query_values || {}
            %w[utm_source utm_medium utm_term utm_content utm_campaign].each do |name|
              self[name] = query_values[name]
            end
          end
        end

        def set_technology
          browser = Browser.new(ua: user_agent)

          self.browser = browser.name

          # TODO add more
          self.os =
            if browser.android?
              "Android"
            elsif browser.ios?
              "iOS"
            elsif browser.windows_phone?
              "Windows Phone"
            elsif browser.blackberry?
              "Blackberry"
            elsif browser.chrome_os?
              "Chrome OS"
            elsif browser.mac?
              "Mac"
            elsif browser.windows?
              "Windows"
            elsif browser.linux?
              "Linux"
            end

          self.device_type =
            if browser.tv?
              "TV"
            elsif browser.console?
              "Console"
            elsif browser.tablet?
              "Tablet"
            elsif browser.mobile?
              "Mobile"
            else
              "Desktop"
            end
        end

        def set_location
          location = Geocoder.search(ip).first rescue nil
          if location
            self.country = location.country.presence
            self.region = location.state.presence
            self.city = location.city.presence
          end
        end

      end # end class_eval
    end

    def visitable
      class_eval do
        belongs_to :visit

        before_create :set_visit

        def set_visit
          if !self.class.column_names.include?("visit_id")
            raise "Add a visit_id column to this table to use visitable"
          else
            self.visit ||= RequestStore.store[:ahoy_controller].try(:send, :current_visit)
          end
        end
      end
    end

  end
end