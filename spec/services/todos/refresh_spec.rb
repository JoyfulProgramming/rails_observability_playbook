# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable all
RSpec.describe Todos::Refresh do
  around do |example|
    perform_enqueued_jobs do
      example.run
    end
  end

  describe '#call_async' do
    context 'when there are no todos' do
      it 'replaces all todos' do
        VCR.use_cassette('all todos') do
          subject.call_async

          expect(Todo.count).to eq(200)
          expect(Todo.first.attributes.symbolize_keys.slice(:id, :title, :completed)).to eq(
            id: 1,
            title: 'delectus aut autem',
            completed: false
          )
        end
      end
    end

    context 'when there are todos' do
      it 'replaces all todos' do
        Todo.create!(id: 1, title: 'old todo', completed: false)

        VCR.use_cassette('all todos') do
          subject.call_async

          expect(Todo.count).to eq(200)
          expect(Todo.find(1).title).to eq('delectus aut autem')
          expect(Todo.find(1).completed).to eq(false)
        end
      end
    end

    context 'it logs the API details' do
      it 'logs the API details' do
        VCR.use_cassette('all todos') do
          info_log = capture_logs { subject.call_async }
                     .select { |log| log[:level] == 'info' }
                     .find { |log| log.dig(:event, :name) == 'http.request.made' }

          expect(info_log.deep_merge(http: { request: { headers: { traceparent: 'traceparent' }}})).to include_payload(
            {
              application: 'Semantic Logger',
              environment: 'test',
              event: {
                name: 'http.request.made'
              },
              http: {
                request: {
                  body: nil,
                  headers: {
                    "User-Agent": 'Faraday v2.9.0',
                    traceparent: 'traceparent'
                  },
                  method: 'GET',
                  url: 'https://jsonplaceholder.typicode.com/todos'
                },
                response: {
                  body: expected_body,
                  headers: {
                    "access-control-allow-credentials": 'true',
                    pragma: 'no-cache',
                    age: '23223',
                    "alt-svc": 'h3=":443"; ma=86400',
                    "cache-control": 'max-age=43200',
                    "cf-cache-status": 'HIT',
                    "cf-ray": '874efaf43e7f956c-LHR',
                    connection: 'keep-alive',
                    "report-to": '{"group":"heroku-nel","max_age":3600,"endpoints":[{"url":"https://nel.heroku.com/reports?ts=1711142612&sid=e11707d5-02a7-43ef-b45e-2cf4d2036f7d&s=osMws1CerRpM6ovykyuiYQ%2BN%2FafzgHrYJr54W3JRqTE%3D"}]}',
                    "reporting-endpoints": 'heroku-nel=https://nel.heroku.com/reports?ts=1711142612&sid=e11707d5-02a7-43ef-b45e-2cf4d2036f7d&s=osMws1CerRpM6ovykyuiYQ%2BN%2FafzgHrYJr54W3JRqTE%3D',
                    nel: '{"report_to":"heroku-nel","max_age":3600,"success_fraction":0.005,"failure_fraction":0.05,"response_headers":["Via"]}',
                    "content-type": 'application/json; charset=utf-8',
                    date: 'Mon, 15 Apr 2024 21:20:33 GMT',
                    etag: 'W/"5ef7-4Ad6/n39KWY9q6Ykm/ULNQ2F5IM"',
                    expires: '-1',
                    server: 'cloudflare',
                    "transfer-encoding": 'chunked',
                    vary: 'Origin, Accept-Encoding',
                    via: '1.1 vegur',
                    "x-content-type-options": 'nosniff',
                    "x-powered-by": 'Express',
                    "x-ratelimit-limit": '1000',
                    "x-ratelimit-remaining": '999',
                    "x-ratelimit-reset": '1711142638'
                  },
                  status_code: 200
                }
              },
              level: 'info',
              level_index: 2,
              message: 'GET https://jsonplaceholder.typicode.com/todos',
              name: 'Rails'
            }
          )
        end
      end
    end

    it "records background job details in the trace" do
      VCR.use_cassette('all todos') do
        subject.call_async
        job_spans = spans.in_root_trace.in_code_namespace("RefreshTodosJob")
        aggregate_failures do
          expect(job_spans.find(&:producer?).attrs).to match(
            "code.namespace" => "RefreshTodosJob",
            "messaging.system" => "active_job",
            "messaging.destination" => "within_five_minutes",
            "messaging.message.id" => active_job_guid_pattern,
            "messaging.active_job.adapter.name" => "async"
          )
          expect(job_spans.find(&:consumer?).attrs).to match(
            "code.namespace" => "RefreshTodosJob",
            "messaging.system" => "active_job",
            "messaging.destination" => "within_five_minutes",
            "messaging.message.id" => active_job_guid_pattern,
            "messaging.active_job.adapter.name" => "async"
          )
        end
      end
    end
  end

  private

  def active_job_guid_pattern
    /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/
  end

  def timestamp_pattern
    /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z$/
  end

# rubocop:disable all
  def expected_body
    [
      {
        completed: false,
        id: 1,
        title: 'delectus aut autem',
        userId: 1
      },
      {
        completed: false,
        id: 2,
        title: 'quis ut nam facilis et officia qui',
        userId: 1
      },
      {
        completed: false,
        id: 3,
        title: 'fugiat veniam minus',
        userId: 1
      },
      {
        completed: true,
        id: 4,
        title: 'et porro tempora',
        userId: 1
      },
      {
        completed: false,
        id: 5,
        title: 'laboriosam mollitia et enim quasi adipisci quia provident illum',
        userId: 1
      },
      {
        completed: false,
        id: 6,
        title: 'qui ullam ratione quibusdam voluptatem quia omnis',
        userId: 1
      },
      {
        completed: false,
        id: 7,
        title: 'illo expedita consequatur quia in',
        userId: 1
      },
      {
        completed: true,
        id: 8,
        title: 'quo adipisci enim quam ut ab',
        userId: 1
      },
      {
        completed: false,
        id: 9,
        title: 'molestiae perspiciatis ipsa',
        userId: 1
      },
      {
        completed: true,
        id: 10,
        title: 'illo est ratione doloremque quia maiores aut',
        userId: 1
      },
      {
        completed: true,
        id: 11,
        title: 'vero rerum temporibus dolor',
        userId: 1
      },
      {
        completed: true,
        id: 12,
        title: 'ipsa repellendus fugit nisi',
        userId: 1
      },
      {
        completed: false,
        id: 13,
        title: 'et doloremque nulla',
        userId: 1
      },
      {
        completed: true,
        id: 14,
        title: 'repellendus sunt dolores architecto voluptatum',
        userId: 1
      },
      {
        completed: true,
        id: 15,
        title: 'ab voluptatum amet voluptas',
        userId: 1
      },
      {
        completed: true,
        id: 16,
        title: 'accusamus eos facilis sint et aut voluptatem',
        userId: 1
      },
      {
        completed: true,
        id: 17,
        title: 'quo laboriosam deleniti aut qui',
        userId: 1
      },
      {
        completed: false,
        id: 18,
        title: 'dolorum est consequatur ea mollitia in culpa',
        userId: 1
      },
      {
        completed: true,
        id: 19,
        title: 'molestiae ipsa aut voluptatibus pariatur dolor nihil',
        userId: 1
      },
      {
        completed: true,
        id: 20,
        title: 'ullam nobis libero sapiente ad optio sint',
        userId: 1
      },
      {
        completed: false,
        id: 21,
        title: 'suscipit repellat esse quibusdam voluptatem incidunt',
        userId: 2
      },
      {
        completed: true,
        id: 22,
        title: 'distinctio vitae autem nihil ut molestias quo',
        userId: 2
      },
      {
        completed: false,
        id: 23,
        title: 'et itaque necessitatibus maxime molestiae qui quas velit',
        userId: 2
      },
      {
        completed: false,
        id: 24,
        title: 'adipisci non ad dicta qui amet quaerat doloribus ea',
        userId: 2
      },
      {
        completed: true,
        id: 25,
        title: 'voluptas quo tenetur perspiciatis explicabo natus',
        userId: 2
      },
      {
        completed: true,
        id: 26,
        title: 'aliquam aut quasi',
        userId: 2
      },
      {
        completed: true,
        id: 27,
        title: 'veritatis pariatur delectus',
        userId: 2
      },
      {
        completed: false,
        id: 28,
        title: 'nesciunt totam sit blanditiis sit',
        userId: 2
      },
      {
        completed: false,
        id: 29,
        title: 'laborum aut in quam',
        userId: 2
      },
      {
        completed: true,
        id: 30,
        title: 'nemo perspiciatis repellat ut dolor libero commodi blanditiis omnis',
        userId: 2
      },
      {
        completed: false,
        id: 31,
        title: 'repudiandae totam in est sint facere fuga',
        userId: 2
      },
      {
        completed: false,
        id: 32,
        title: 'earum doloribus ea doloremque quis',
        userId: 2
      },
      {
        completed: false,
        id: 33,
        title: 'sint sit aut vero',
        userId: 2
      },
      {
        completed: false,
        id: 34,
        title: 'porro aut necessitatibus eaque distinctio',
        userId: 2
      },
      {
        completed: true,
        id: 35,
        title: 'repellendus veritatis molestias dicta incidunt',
        userId: 2
      },
      {
        completed: true,
        id: 36,
        title: 'excepturi deleniti adipisci voluptatem et neque optio illum ad',
        userId: 2
      },
      {
        completed: false,
        id: 37,
        title: 'sunt cum tempora',
        userId: 2
      },
      {
        completed: false,
        id: 38,
        title: 'totam quia non',
        userId: 2
      },
      {
        completed: false,
        id: 39,
        title: 'doloremque quibusdam asperiores libero corrupti illum qui omnis',
        userId: 2
      },
      {
        completed: true,
        id: 40,
        title: 'totam atque quo nesciunt',
        userId: 2
      },
      {
        completed: false,
        id: 41,
        title: 'aliquid amet impedit consequatur aspernatur placeat eaque fugiat suscipit',
        userId: 3
      },
      {
        completed: false,
        id: 42,
        title: 'rerum perferendis error quia ut eveniet',
        userId: 3
      },
      {
        completed: true,
        id: 43,
        title: 'tempore ut sint quis recusandae',
        userId: 3
      },
      {
        completed: true,
        id: 44,
        title: 'cum debitis quis accusamus doloremque ipsa natus sapiente omnis',
        userId: 3
      },
      {
        completed: false,
        id: 45,
        title: 'velit soluta adipisci molestias reiciendis harum',
        userId: 3
      },
      {
        completed: false,
        id: 46,
        title: 'vel voluptatem repellat nihil placeat corporis',
        userId: 3
      },
      {
        completed: false,
        id: 47,
        title: 'nam qui rerum fugiat accusamus',
        userId: 3
      },
      {
        completed: false,
        id: 48,
        title: 'sit reprehenderit omnis quia',
        userId: 3
      },
      {
        completed: false,
        id: 49,
        title: 'ut necessitatibus aut maiores debitis officia blanditiis velit et',
        userId: 3
      },
      {
        completed: true,
        id: 50,
        title: 'cupiditate necessitatibus ullam aut quis dolor voluptate',
        userId: 3
      },
      {
        completed: false,
        id: 51,
        title: 'distinctio exercitationem ab doloribus',
        userId: 3
      },
      {
        completed: false,
        id: 52,
        title: 'nesciunt dolorum quis recusandae ad pariatur ratione',
        userId: 3
      },
      {
        completed: false,
        id: 53,
        title: 'qui labore est occaecati recusandae aliquid quam',
        userId: 3
      },
      {
        completed: true,
        id: 54,
        title: 'quis et est ut voluptate quam dolor',
        userId: 3
      },
      {
        completed: true,
        id: 55,
        title: 'voluptatum omnis minima qui occaecati provident nulla voluptatem ratione',
        userId: 3
      },
      {
        completed: true,
        id: 56,
        title: 'deleniti ea temporibus enim',
        userId: 3
      },
      {
        completed: false,
        id: 57,
        title: 'pariatur et magnam ea doloribus similique voluptatem rerum quia',
        userId: 3
      },
      {
        completed: false,
        id: 58,
        title: 'est dicta totam qui explicabo doloribus qui dignissimos',
        userId: 3
      },
      {
        completed: false,
        id: 59,
        title: 'perspiciatis velit id laborum placeat iusto et aliquam odio',
        userId: 3
      },
      {
        completed: true,
        id: 60,
        title: 'et sequi qui architecto ut adipisci',
        userId: 3
      },
      {
        completed: true,
        id: 61,
        title: 'odit optio omnis qui sunt',
        userId: 4
      },
      {
        completed: false,
        id: 62,
        title: 'et placeat et tempore aspernatur sint numquam',
        userId: 4
      },
      {
        completed: true,
        id: 63,
        title: 'doloremque aut dolores quidem fuga qui nulla',
        userId: 4
      },
      {
        completed: false,
        id: 64,
        title: 'voluptas consequatur qui ut quia magnam nemo esse',
        userId: 4
      },
      {
        completed: false,
        id: 65,
        title: 'fugiat pariatur ratione ut asperiores necessitatibus magni',
        userId: 4
      },
      {
        completed: false,
        id: 66,
        title: 'rerum eum molestias autem voluptatum sit optio',
        userId: 4
      },
      {
        completed: false,
        id: 67,
        title: 'quia voluptatibus voluptatem quos similique maiores repellat',
        userId: 4
      },
      {
        completed: false,
        id: 68,
        title: 'aut id perspiciatis voluptatem iusto',
        userId: 4
      },
      {
        completed: false,
        id: 69,
        title: 'doloribus sint dolorum ab adipisci itaque dignissimos aliquam suscipit',
        userId: 4
      },
      {
        completed: false,
        id: 70,
        title: 'ut sequi accusantium et mollitia delectus sunt',
        userId: 4
      },
      {
        completed: false,
        id: 71,
        title: 'aut velit saepe ullam',
        userId: 4
      },
      {
        completed: false,
        id: 72,
        title: 'praesentium facilis facere quis harum voluptatibus voluptatem eum',
        userId: 4
      },
      {
        completed: true,
        id: 73,
        title: 'sint amet quia totam corporis qui exercitationem commodi',
        userId: 4
      },
      {
        completed: false,
        id: 74,
        title: 'expedita tempore nobis eveniet laborum maiores',
        userId: 4
      },
      {
        completed: false,
        id: 75,
        title: 'occaecati adipisci est possimus totam',
        userId: 4
      },
      {
        completed: true,
        id: 76,
        title: 'sequi dolorem sed',
        userId: 4
      },
      {
        completed: false,
        id: 77,
        title: 'maiores aut nesciunt delectus exercitationem vel assumenda eligendi at',
        userId: 4
      },
      {
        completed: false,
        id: 78,
        title: 'reiciendis est magnam amet nemo iste recusandae impedit quaerat',
        userId: 4
      },
      {
        completed: true,
        id: 79,
        title: 'eum ipsa maxime ut',
        userId: 4
      },
      {
        completed: true,
        id: 80,
        title: 'tempore molestias dolores rerum sequi voluptates ipsum consequatur',
        userId: 4
      },
      {
        completed: true,
        id: 81,
        title: 'suscipit qui totam',
        userId: 5
      },
      {
        completed: false,
        id: 82,
        title: 'voluptates eum voluptas et dicta',
        userId: 5
      },
      {
        completed: true,
        id: 83,
        title: 'quidem at rerum quis ex aut sit quam',
        userId: 5
      },
      {
        completed: false,
        id: 84,
        title: 'sunt veritatis ut voluptate',
        userId: 5
      },
      {
        completed: true,
        id: 85,
        title: 'et quia ad iste a',
        userId: 5
      },
      {
        completed: true,
        id: 86,
        title: 'incidunt ut saepe autem',
        userId: 5
      },
      {
        completed: true,
        id: 87,
        title: 'laudantium quae eligendi consequatur quia et vero autem',
        userId: 5
      },
      {
        completed: false,
        id: 88,
        title: 'vitae aut excepturi laboriosam sint aliquam et et accusantium',
        userId: 5
      },
      {
        completed: true,
        id: 89,
        title: 'sequi ut omnis et',
        userId: 5
      },
      {
        completed: true,
        id: 90,
        title: 'molestiae nisi accusantium tenetur dolorem et',
        userId: 5
      },
      {
        completed: true,
        id: 91,
        title: 'nulla quis consequatur saepe qui id expedita',
        userId: 5
      },
      {
        completed: true,
        id: 92,
        title: 'in omnis laboriosam',
        userId: 5
      },
      {
        completed: true,
        id: 93,
        title: 'odio iure consequatur molestiae quibusdam necessitatibus quia sint',
        userId: 5
      },
      {
        completed: false,
        id: 94,
        title: 'facilis modi saepe mollitia',
        userId: 5
      },
      {
        completed: true,
        id: 95,
        title: 'vel nihil et molestiae iusto assumenda nemo quo ut',
        userId: 5
      },
      {
        completed: false,
        id: 96,
        title: 'nobis suscipit ducimus enim asperiores voluptas',
        userId: 5
      },
      {
        completed: false,
        id: 97,
        title: 'dolorum laboriosam eos qui iure aliquam',
        userId: 5
      },
      {
        completed: true,
        id: 98,
        title: 'debitis accusantium ut quo facilis nihil quis sapiente necessitatibus',
        userId: 5
      },
      {
        completed: false,
        id: 99,
        title: 'neque voluptates ratione',
        userId: 5
      },
      {
        completed: false,
        id: 100,
        title: 'excepturi a et neque qui expedita vel voluptate',
        userId: 5
      },
      {
        completed: false,
        id: 101,
        title: 'explicabo enim cumque porro aperiam occaecati minima',
        userId: 6
      },
      {
        completed: false,
        id: 102,
        title: 'sed ab consequatur',
        userId: 6
      },
      {
        completed: false,
        id: 103,
        title: 'non sunt delectus illo nulla tenetur enim omnis',
        userId: 6
      },
      {
        completed: false,
        id: 104,
        title: 'excepturi non laudantium quo',
        userId: 6
      },
      {
        completed: true,
        id: 105,
        title: 'totam quia dolorem et illum repellat voluptas optio',
        userId: 6
      },
      {
        completed: true,
        id: 106,
        title: 'ad illo quis voluptatem temporibus',
        userId: 6
      },
      {
        completed: false,
        id: 107,
        title: 'praesentium facilis omnis laudantium fugit ad iusto nihil nesciunt',
        userId: 6
      },
      {
        completed: true,
        id: 108,
        title: 'a eos eaque nihil et exercitationem incidunt delectus',
        userId: 6
      },
      {
        completed: true,
        id: 109,
        title: 'autem temporibus harum quisquam in culpa',
        userId: 6
      },
      {
        completed: true,
        id: 110,
        title: 'aut aut ea corporis',
        userId: 6
      },
      {
        completed: false,
        id: 111,
        title: 'magni accusantium labore et id quis provident',
        userId: 6
      },
      {
        completed: false,
        id: 112,
        title: 'consectetur impedit quisquam qui deserunt non rerum consequuntur eius',
        userId: 6
      },
      {
        completed: false,
        id: 113,
        title: 'quia atque aliquam sunt impedit voluptatum rerum assumenda nisi',
        userId: 6
      },
      {
        completed: false,
        id: 114,
        title: 'cupiditate quos possimus corporis quisquam exercitationem beatae',
        userId: 6
      },
      {
        completed: false,
        id: 115,
        title: 'sed et ea eum',
        userId: 6
      },
      {
        completed: true,
        id: 116,
        title: 'ipsa dolores vel facilis ut',
        userId: 6
      },
      {
        completed: false,
        id: 117,
        title: 'sequi quae est et qui qui eveniet asperiores',
        userId: 6
      },
      {
        completed: false,
        id: 118,
        title: 'quia modi consequatur vero fugiat',
        userId: 6
      },
      {
        completed: false,
        id: 119,
        title: 'corporis ducimus ea perspiciatis iste',
        userId: 6
      },
      {
        completed: false,
        id: 120,
        title: 'dolorem laboriosam vel voluptas et aliquam quasi',
        userId: 6
      },
      {
        completed: true,
        id: 121,
        title: 'inventore aut nihil minima laudantium hic qui omnis',
        userId: 7
      },
      {
        completed: true,
        id: 122,
        title: 'provident aut nobis culpa',
        userId: 7
      },
      {
        completed: false,
        id: 123,
        title: 'esse et quis iste est earum aut impedit',
        userId: 7
      },
      {
        completed: false,
        id: 124,
        title: 'qui consectetur id',
        userId: 7
      },
      {
        completed: false,
        id: 125,
        title: 'aut quasi autem iste tempore illum possimus',
        userId: 7
      },
      {
        completed: true,
        id: 126,
        title: 'ut asperiores perspiciatis veniam ipsum rerum saepe',
        userId: 7
      },
      {
        completed: true,
        id: 127,
        title: 'voluptatem libero consectetur rerum ut',
        userId: 7
      },
      {
        completed: false,
        id: 128,
        title: 'eius omnis est qui voluptatem autem',
        userId: 7
      },
      {
        completed: false,
        id: 129,
        title: 'rerum culpa quis harum',
        userId: 7
      },
      {
        completed: true,
        id: 130,
        title: 'nulla aliquid eveniet harum laborum libero alias ut unde',
        userId: 7
      },
      {
        completed: false,
        id: 131,
        title: 'qui ea incidunt quis',
        userId: 7
      },
      {
        completed: true,
        id: 132,
        title: 'qui molestiae voluptatibus velit iure harum quisquam',
        userId: 7
      },
      {
        completed: true,
        id: 133,
        title: 'et labore eos enim rerum consequatur sunt',
        userId: 7
      },
      {
        completed: false,
        id: 134,
        title: 'molestiae doloribus et laborum quod ea',
        userId: 7
      },
      {
        completed: false,
        id: 135,
        title: 'facere ipsa nam eum voluptates reiciendis vero qui',
        userId: 7
      },
      {
        completed: false,
        id: 136,
        title: 'asperiores illo tempora fuga sed ut quasi adipisci',
        userId: 7
      },
      {
        completed: false,
        id: 137,
        title: 'qui sit non',
        userId: 7
      },
      {
        completed: true,
        id: 138,
        title: 'placeat minima consequatur rem qui ut',
        userId: 7
      },
      {
        completed: false,
        id: 139,
        title: 'consequatur doloribus id possimus voluptas a voluptatem',
        userId: 7
      },
      {
        completed: true,
        id: 140,
        title: 'aut consectetur in blanditiis deserunt quia sed laboriosam',
        userId: 7
      },
      {
        completed: true,
        id: 141,
        title: 'explicabo consectetur debitis voluptates quas quae culpa rerum non',
        userId: 8
      },
      {
        completed: true,
        id: 142,
        title: 'maiores accusantium architecto necessitatibus reiciendis ea aut',
        userId: 8
      },
      {
        completed: false,
        id: 143,
        title: 'eum non recusandae cupiditate animi',
        userId: 8
      },
      {
        completed: false,
        id: 144,
        title: 'ut eum exercitationem sint',
        userId: 8
      },
      {
        completed: false,
        id: 145,
        title: 'beatae qui ullam incidunt voluptatem non nisi aliquam',
        userId: 8
      },
      {
        completed: true,
        id: 146,
        title: 'molestiae suscipit ratione nihil odio libero impedit vero totam',
        userId: 8
      },
      {
        completed: true,
        id: 147,
        title: 'eum itaque quod reprehenderit et facilis dolor autem ut',
        userId: 8
      },
      {
        completed: false,
        id: 148,
        title: 'esse quas et quo quasi exercitationem',
        userId: 8
      },
      {
        completed: false,
        id: 149,
        title: 'animi voluptas quod perferendis est',
        userId: 8
      },
      {
        completed: false,
        id: 150,
        title: 'eos amet tempore laudantium fugit a',
        userId: 8
      },
      {
        completed: true,
        id: 151,
        title: 'accusamus adipisci dicta qui quo ea explicabo sed vero',
        userId: 8
      },
      {
        completed: false,
        id: 152,
        title: 'odit eligendi recusandae doloremque cumque non',
        userId: 8
      },
      {
        completed: false,
        id: 153,
        title: 'ea aperiam consequatur qui repellat eos',
        userId: 8
      },
      {
        completed: true,
        id: 154,
        title: 'rerum non ex sapiente',
        userId: 8
      },
      {
        completed: true,
        id: 155,
        title: 'voluptatem nobis consequatur et assumenda magnam',
        userId: 8
      },
      {
        completed: true,
        id: 156,
        title: 'nam quia quia nulla repellat assumenda quibusdam sit nobis',
        userId: 8
      },
      {
        completed: true,
        id: 157,
        title: 'dolorem veniam quisquam deserunt repellendus',
        userId: 8
      },
      {
        completed: true,
        id: 158,
        title: 'debitis vitae delectus et harum accusamus aut deleniti a',
        userId: 8
      },
      {
        completed: true,
        id: 159,
        title: 'debitis adipisci quibusdam aliquam sed dolore ea praesentium nobis',
        userId: 8
      },
      {
        completed: false,
        id: 160,
        title: 'et praesentium aliquam est',
        userId: 8
      },
      {
        completed: true,
        id: 161,
        title: 'ex hic consequuntur earum omnis alias ut occaecati culpa',
        userId: 9
      },
      {
        completed: true,
        id: 162,
        title: 'omnis laboriosam molestias animi sunt dolore',
        userId: 9
      },
      {
        completed: false,
        id: 163,
        title: 'natus corrupti maxime laudantium et voluptatem laboriosam odit',
        userId: 9
      },
      {
        completed: false,
        id: 164,
        title: 'reprehenderit quos aut aut consequatur est sed',
        userId: 9
      },
      {
        completed: false,
        id: 165,
        title: 'fugiat perferendis sed aut quidem',
        userId: 9
      },
      {
        completed: false,
        id: 166,
        title: 'quos quo possimus suscipit minima ut',
        userId: 9
      },
      {
        completed: false,
        id: 167,
        title: 'et quis minus quo a asperiores molestiae',
        userId: 9
      },
      {
        completed: false,
        id: 168,
        title: 'recusandae quia qui sunt libero',
        userId: 9
      },
      {
        completed: true,
        id: 169,
        title: 'ea odio perferendis officiis',
        userId: 9
      },
      {
        completed: false,
        id: 170,
        title: 'quisquam aliquam quia doloribus aut',
        userId: 9
      },
      {
        completed: true,
        id: 171,
        title: 'fugiat aut voluptatibus corrupti deleniti velit iste odio',
        userId: 9
      },
      {
        completed: false,
        id: 172,
        title: 'et provident amet rerum consectetur et voluptatum',
        userId: 9
      },
      {
        completed: false,
        id: 173,
        title: 'harum ad aperiam quis',
        userId: 9
      },
      {
        completed: false,
        id: 174,
        title: 'similique aut quo',
        userId: 9
      },
      {
        completed: true,
        id: 175,
        title: 'laudantium eius officia perferendis provident perspiciatis asperiores',
        userId: 9
      },
      {
        completed: false,
        id: 176,
        title: 'magni soluta corrupti ut maiores rem quidem',
        userId: 9
      },
      {
        completed: false,
        id: 177,
        title: 'et placeat temporibus voluptas est tempora quos quibusdam',
        userId: 9
      },
      {
        completed: true,
        id: 178,
        title: 'nesciunt itaque commodi tempore',
        userId: 9
      },
      {
        completed: true,
        id: 179,
        title: 'omnis consequuntur cupiditate impedit itaque ipsam quo',
        userId: 9
      },
      {
        completed: true,
        id: 180,
        title: 'debitis nisi et dolorem repellat et',
        userId: 9
      },
      {
        completed: false,
        id: 181,
        title: 'ut cupiditate sequi aliquam fuga maiores',
        userId: 10
      },
      {
        completed: true,
        id: 182,
        title: 'inventore saepe cumque et aut illum enim',
        userId: 10
      },
      {
        completed: true,
        id: 183,
        title: 'omnis nulla eum aliquam distinctio',
        userId: 10
      },
      {
        completed: false,
        id: 184,
        title: 'molestias modi perferendis perspiciatis',
        userId: 10
      },
      {
        completed: false,
        id: 185,
        title: 'voluptates dignissimos sed doloribus animi quaerat aut',
        userId: 10
      },
      {
        completed: false,
        id: 186,
        title: 'explicabo odio est et',
        userId: 10
      },
      {
        completed: false,
        id: 187,
        title: 'consequuntur animi possimus',
        userId: 10
      },
      {
        completed: true,
        id: 188,
        title: 'vel non beatae est',
        userId: 10
      },
      {
        completed: true,
        id: 189,
        title: 'culpa eius et voluptatem et',
        userId: 10
      },
      {
        completed: true,
        id: 190,
        title: 'accusamus sint iusto et voluptatem exercitationem',
        userId: 10
      },
      {
        completed: true,
        id: 191,
        title: 'temporibus atque distinctio omnis eius impedit tempore molestias pariatur',
        userId: 10
      },
      {
        completed: false,
        id: 192,
        title: 'ut quas possimus exercitationem sint voluptates',
        userId: 10
      },
      {
        completed: true,
        id: 193,
        title: 'rerum debitis voluptatem qui eveniet tempora distinctio a',
        userId: 10
      },
      {
        completed: false,
        id: 194,
        title: 'sed ut vero sit molestiae',
        userId: 10
      },
      {
        completed: true,
        id: 195,
        title: 'rerum ex veniam mollitia voluptatibus pariatur',
        userId: 10
      },
      {
        completed: true,
        id: 196,
        title: 'consequuntur aut ut fugit similique',
        userId: 10
      },
      {
        completed: true,
        id: 197,
        title: 'dignissimos quo nobis earum saepe',
        userId: 10
      },
      {
        completed: true,
        id: 198,
        title: 'quis eius est sint explicabo',
        userId: 10
      },
      {
        completed: true,
        id: 199,
        title: 'numquam repellendus a magnam',
        userId: 10
      },
      {
        completed: false,
        id: 200,
        title: 'ipsam aperiam voluptates qui',
        userId: 10
      }
    ]
  end
# rubocop:enable all
end
