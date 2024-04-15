class FetchTodos
  def initialize
    @todo_api = Faraday.new(url: "https://jsonplaceholder.typicode.com/todos") do |conn|
      conn.request :json
      conn.response :json
    end
  end

  def call
    todos = @todo_api.get("/todos").body.map { |todo| todo.slice("id", "title", "completed") }
    Todo.destroy_all
    Todo.create!(todos)
  end
end