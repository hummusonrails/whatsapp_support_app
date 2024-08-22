require 'couchbase-orm'

class Ticket < CouchbaseOrm::Base
  belongs_to :user
  belongs_to :agent, optional: true

  attribute :query, :string
  attribute :status, :string, default: 'open'
  attribute :summary, :string
  attribute :embedding, :array, type: :float, default: []
  attribute :created_at, :datetime, default: -> { Time.now }
  attribute :updated_at, :datetime, default: -> { Time.now }

  validates :query, presence: true

  enum status: %i[open resolved]

  before_save :set_timestamps

  private

  def set_timestamps
    self.updated_at = Time.now
  end
end
