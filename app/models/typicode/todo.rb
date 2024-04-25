# frozen_string_literal: true

module Typicode
  # Path: app/models/typicode/todo.rb
  class Todo < Dry::Struct
    attribute :id, Dry.Types::Integer
    attribute :title, Dry.Types::String
    attribute :completed, Dry.Types::Bool

    def self.all
      api.get('/todos').body.map { |todo| new(todo) }
    end

    def self.api
      Faraday.new(url: 'https://jsonplaceholder.typicode.com/todos') do |conn|
        conn.use FaradayLogging
        conn.request :json
        conn.response :json, parser_options: { symbolize_names: true }
      end
    end
  end
end
