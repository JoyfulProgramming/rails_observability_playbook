# frozen_string_literal: true

# This class represents a job that refreshes todos.
class RefreshTodosJob
  include Sidekiq::Job
  sidekiq_options queue: :within_five_minutes, retry: 2

  # Performs the job by calling the RefreshTodos service.
  def perform
    Todos::Refresh.new.call
  end
end
