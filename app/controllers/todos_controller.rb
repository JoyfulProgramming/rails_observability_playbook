# frozen_string_literal: true

# Path: app/controllers/todos_controller.rb
class TodosController < ApplicationController
  def index
    @todos = Todo.all
  end

  def refresh
    RefreshTodos.new.call_async
    redirect_to root_path
  end
end
