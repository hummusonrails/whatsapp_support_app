class DashboardController < ApplicationController
  def index
    @open_tickets = Ticket.where(status: ['open', 1]).to_a.sort_by { |ticket| ticket.created_at }.reverse
    @resolved_tickets = Ticket.all.to_a.select { |ticket| ticket.status == Ticket::RESOLVED }.to_a.sort_by { |ticket| ticket.updated_at }.reverse
  end

  def show
    @ticket = find_ticket
    @user = find_user
    @suggestions = find_suggestions
  end

  private
  def find_ticket
    Ticket.find(params[:id])
  end

  def find_user
    find_ticket.user
  end

  def find_suggestions
    search_similar_tickets(find_ticket.query)
  end

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
