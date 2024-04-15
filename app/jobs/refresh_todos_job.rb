class RefreshTodosJob < ApplicationJob
  queue_as :default

  def perform(*args)
    RefreshTodos.new.call
  end
end
