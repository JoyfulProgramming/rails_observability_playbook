class TodosController < ApplicationController
  def index
    @todos = Todo.all
  end

  def refresh
    RefreshTodos.new.call_async
    redirect_to root_path
  end
end
