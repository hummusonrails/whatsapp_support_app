class DashboardController < ApplicationController
  def index
    @tickets = Ticket.where(status: 'open').to_a.sort_by { |ticket| ticket.created_at }.reverse
  end

  def show
    @ticket = Ticket.find(params[:id])
    @user = @ticket.user
    @suggestions = search_similar_tickets(@ticket.query)
  end

  private

  def search_similar_tickets(query)
    embedding = OPENAI_CLIENT.embeddings(
      parameters: {
        model: "text-embedding-ada-002",
        input: query
      }
    )['data'][0]['embedding']

    cluster = Couchbase::Cluster.connect(
      ENV['COUCHBASE_CONNECTION_STRING'],
      ENV['COUCHBASE_USERNAME'],
      ENV['COUCHBASE_PASSWORD']
    )

    bucket = cluster.bucket(ENV['COUCHBASE_BUCKET'])

    scope = bucket.scope('_default')

    request = Couchbase::SearchRequest.new(
      Couchbase::VectorSearch.new(
        [
          Couchbase::VectorQuery.new('embedding', embedding) do |q|
            q.num_candidates = 2
            q.boost = 0.3
          end
        ],
        Couchbase::Options::VectorSearch.new(vector_query_combination: :and)
      )
    )

    result = scope.search('whatsapp_support_index', request)

    result.rows.map do |row|
      document = bucket.default_collection.get(row.id)
      {
        id: row.id,
        score: row.score,
        summary: document.content['summary']
      }
    end
  end
end
