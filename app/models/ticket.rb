require 'couchbase-orm'

class Ticket < CouchbaseOrm::Base
  OPEN = 'open'
  RESOLVED = 'resolved'

  belongs_to :user
  belongs_to :agent, optional: true

  attribute :query, :string
  attribute :status, :string, default: OPEN
  attribute :summary, :string
  attribute :embedding, :array, type: :float, default: []
  attribute :created_at, :datetime, default: -> { Time.now }
  attribute :updated_at, :datetime, default: -> { Time.now }

  ensure_design_document!

  validates :query, presence: true

  before_save :set_timestamps
  def self.open_tickets
    where(status: OPEN).to_a
  end

  def self.resolved_tickets
    where(status: RESOLVED).to_a
  end

  def open?
    status == OPEN
  end

  def resolved?
    status == RESOLVED
  end

  def mark_as_resolved!
    update!(status: RESOLVED)
  end

  private

  def set_timestamps
    self.updated_at = Time.now
  end
end
