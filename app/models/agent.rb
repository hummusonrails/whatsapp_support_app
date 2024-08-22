require 'couchbase-orm'

class Agent < CouchbaseOrm::Base
  has_many :tickets

  attribute :name, :string
  attribute :email, :string
  attribute :created_at, :datetime, default: -> { Time.now }
  attribute :updated_at, :datetime, default: -> { Time.now }

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true

  before_save :set_timestamps

  private

  def set_timestamps
    self.updated_at = Time.now
  end
end
