require 'capistrano'
require 'net/http'
require 'uri'
require 'json'
require 'capistrano/teams/message/types'

module Capistrano
  module Teams
    # Teams Webhook class
    class WebHook
      def initialize(cap_instance)
        @cap = cap_instance
      end

      def notify(
        status = @cap.fetch(:teams_default_status),
        theme_color = @cap.fetch(:teams_default_color),
        facts = []
      )
        content = Message::Builder.of_type(
          @cap,
          @cap.fetch(:teams_message_type),
          {
            status: status
          }.merge(@cap.fetch(:teams_placeholder_list)),
          theme_color,
          facts
        ).content
        send_message_to_webhook(content)
      end

      # Post to Teams.
      def send_message_to_webhook(body)
        uri = URI.parse(@cap.fetch(:teams_webhook_url).to_s)
        request = Net::HTTP::Post.new(uri.path)
        request.content_type = 'application/json'
        request.body = body

        opts = { use_ssl: uri.scheme == 'https' } \
               .merge(@cap.fetch(:teams_http_options))

        Net::HTTP.start(uri.host, uri.port, opts) do |http|
          http.request(request)
        end
      end
    end
  end
end
