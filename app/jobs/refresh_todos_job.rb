# frozen_string_literal: true

# This class represents a job that refreshes todos.
class RefreshTodosJob < ApplicationJob
  queue_as :default

  # Performs the job by calling the RefreshTodos service.
  def perform
    Todos::Refresh.new.call
  end
end
