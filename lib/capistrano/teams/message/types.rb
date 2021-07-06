# frozen_string_literal: true

require 'capistrano/teams/message/placeholders'

module Message
  TYPE_BASIC = 1
  TYPE_CARD = 2
  # Message builder class
  class Builder
    def self.of_type(cap_instance, type, placeholder_list, theme_color, facts)
      case type
      when Message::TYPE_BASIC
        Basic.new(cap_instance, placeholder_list, theme_color, facts)
      when Message::TYPE_CARD
        MessageCard.new(cap_instance, placeholder_list, theme_color, facts)
      else
        raise 'Capistrano Teams: Unknown message type'
      end
    end
  end

  # Type
  class Type
    def initialize(cap_instance, placeholder_list, theme_color, facts = [])
      @cap = cap_instance
      @placeholder_list = placeholder_list
      @theme_color = theme_color
      @facts = facts
    end

    def placeholders
      Message::Placeholders.new(@cap, @placeholder_list).placeholders
    end

    def content
      raise 'Abstract method called'
    end
  end

  # Basic type
  class Basic < Type
    # Get the body of the POST message as JSON.
    def content
      {
        title: @cap.fetch(:teams_basic_message_title),
        text: @cap.fetch(:teams_basic_message_text),
        themeColor: @theme_color
      }.to_json % placeholders
    end
  end

  # MessageCard type
  class MessageCard < Type
    # Get the body of the POST message as JSON.
    def content
      {
        '@type' => 'MessageCard',
        '@context' => 'http://schema.org/extensions',
        'themeColor' => @theme_color,
        'summary' => @cap.fetch(:teams_card_message_summary),
        'sections' => sections,
        'potentialAction' => []
      }.to_json % placeholders
    end

    private

    def sections
      [{
        'activityTitle' => @cap.fetch(:teams_card_message_title),
        'activitySubtitle' => @cap.fetch(:teams_card_message_sub_title),
        'activityImage' => @cap.fetch(:teams_card_message_image),
        'facts' => facts,
        'markdown' => @cap.fetch(:teams_card_message_markdown)
      }]
    end

    def facts
      [
        {
          'name' => 'Deploy by',
          'value' => '%<user>s'
        },
        {
          'name' => 'Branch',
          'value' => '%<branch>s'
        },
        {
          'name' => 'Deploy date',
          'value' => Time.now.strftime('%d/%m/%Y %H:%M:%S')
        }, {
          'name' => 'Status',
          'value' => '%<status>s'
        }
      ].concat(@facts)
    end
  end
end
