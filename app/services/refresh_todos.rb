class RefreshTodos
  def call_async
    RefreshTodosJob.perform_later
  end

  def call
    latest_todos = Typicode::Todo.all
    Todo.destroy_all
    Todo.create!(latest_todos.map(&:to_h))
  end
end