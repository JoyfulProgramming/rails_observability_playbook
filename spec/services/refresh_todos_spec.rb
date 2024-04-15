require "rails_helper"

RSpec.describe RefreshTodos do
  around do |example|
    perform_enqueued_jobs do
      example.run
    end
  end

  describe "#call_async" do
    context "when there are no todos" do
      it "replaces all todos" do
        VCR.use_cassette("all todos") do
          subject.call_async

          expect(Todo.count).to eq(200)
          expect(Todo.first.attributes.symbolize_keys.slice(:id, :title, :completed)).to eq(
            id: 1,
            title: "delectus aut autem",
            completed: false
          )
        end
      end
    end

    context "when there are todos" do
      it "replaces all todos" do
        Todo.create!(id: 1, title: "old todo", completed: false)

        VCR.use_cassette("all todos") do
          subject.call_async

          expect(Todo.count).to eq(200)
          expect(Todo.find(1).title).to eq("delectus aut autem")
          expect(Todo.find(1).completed).to eq(false)
        end
      end
    end

    context "it logs the API details" do
      it "logs the API details" do
        VCR.use_cassette("all todos") do
          info_logs = capture_logs { subject.call_async }
                        .select { |log| log["level"] == "info" }
          expect(info_logs).to eq([])
        end
      end
    end
  end
end
