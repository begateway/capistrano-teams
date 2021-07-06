Capistrano::Configuration.instance.load do

  # Teams defaults

  # set :teams_webhook_url,  "url"
  _cset(:teams_suppress_events) { false }
  _cset(:teams_message_type) { Message::TYPE_BASIC } # Message::TYPE_BASIC or Message::TYPE_CARD
  _cset(:teams_http_options) { Hash.new(verify_mode: OpenSSL::SSL::VERIFY_PEER) }

  # Theme colors
  _cset(:teams_starting_color) { '0033CC' }
  _cset(:teams_reverting_color) { 'FFFF00' }
  _cset(:teams_finishing_color) { '00FF00' }
  _cset(:teams_rollback_color) { 'FFFF00' }
  _cset(:teams_failed_color) { 'FF0000' }

  # Statuses
  _cset(:teams_starting_status) { 'STARTING' }
  _cset(:teams_reverting_status) { 'REVERTING' }
  _cset(:teams_finishing_status) { 'FINISHED' }
  _cset(:teams_rollback_status) { 'ROLLBACK' }
  _cset(:teams_failed_status) { 'FAILED' }

  # Used for Message::TYPE_BASIC
  _cset(:teams_placeholder_list) { Hash.new }
  _cset(:teams_basic_message_title) { 'Deployment Notice » %{application}s' }
  _cset(:teams_basic_message_text) { '<h1>Deploy on <strong>%{stage}</strong> by ' \
        '<strong>%{user}</strong></h1> ' \
        "Branch: %{branch} \n\n" \
        'Status: %{status}' }

  # Used for Message::TYPE_CARD
  _cset(:teams_card_message_title) { 'Deployment Notice » %{application}' }
  _cset(:teams_card_message_sub_title) { 'On %{stage}' }
  _cset(:teams_card_message_image) { '' }
  _cset(:teams_card_message_summary) { 'Deploy for %{application} on %{stage} by %{user}' }
  _cset(:teams_card_message_markdown) { false }

  # Default values
  _cset(:teams_default_color) { '333333' }
  _cset(:teams_default_status) { 'UNKNOWN' }
  _cset(:teams_default_application) { 'N/A' }
  _cset(:teams_default_branch) { 'N/A' }
  _cset(:teams_default_stage) { 'N/A' }
  _cset(:teams_default_user) { 'UNKNOWN' }

  namespace :teams do
    namespace :deploy do
      task :starting do |task|
        notify_event(fetch(:teams_starting_status), fetch(:teams_starting_color))
        #task.reenable
      end

      task :reverting do |task|
        notify_event(fetch(:teams_reverting_status), fetch(:teams_reverting_color))
        #task.reenable
      end

      task :finishing do |task|
        notify_event(fetch(:teams_finishing_status), fetch(:teams_finishing_color))
        #task.reenable
      end

      task :finishing_rollback do |task|
        notify_event(fetch(:teams_rollback_status), fetch(:teams_rollback_color))
        #task.reenable
      end

      task :failed do |task|
        notify_event(fetch(:teams_failed_status), fetch(:teams_failed_color))
        #task.reenable
      end
    end
  end

  def send_notification(status, color, facts)
    Capistrano::Teams::WebHook.new(self).notify(status, color, facts)
    puts "'#{status.capitalize}' event notification sent to teams."
  end

  def notify_event(status, color)
    if fetch(:teams_suppress_events) == false
      send_notification(status, color, [])
    else
      puts 'Notification not sent, `teams_suppress_events` is set to true or is invalid.'
    end
  end
end
