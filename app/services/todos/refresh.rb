# frozen_string_literal: true

module Todos
  # A service that refreshes todos.
  class Refresh
    def call_async
      RefreshTodosJob.perform_async
    end

    def call
      latest_todos = Typicode::Todo.all
      Todo.destroy_all
      Todo.create!(latest_todos.map(&:to_h))
    end
  end
end
