require "rails_helper"

RSpec.describe FetchTodos do
  around do |example|
    perform_enqueued_jobs do
      example.run
    end
  end

  context "when there are no todos" do
    it "replaces all Todos" do
      VCR.use_cassette("all todos") do
        FetchTodos.new.call

        expect(Todo.count).to eq(200)
        expect(Todo.first.attributes.symbolize_keys.slice(:id, :title, :completed)).to eq(
          id: 1,
          title: "delectus aut autem",
          completed: false
        )
      end
    end
  end
end
