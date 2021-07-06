# frozen_string_literal: true

module Message
  # Placeholder
  class Placeholders
    attr_reader :placeholders

    def initialize(cap_instance, placeholders)
      @cap = cap_instance
      @placeholders = defaults.merge(placeholders)
    end

    private

    def defaults
      {
        application: @cap.fetch(:application, @cap.fetch(:teams_default_application)),
        branch: @cap.fetch(:branch, @cap.fetch(:teams_default_branch)),
        stage: @cap.fetch(:stage, :teams_default_stage),
        user: ENV.fetch('USER', ENV.fetch('USERNAME', @cap.fetch(:teams_default_user)))
      }
    end
  end
end
