require 'couchbase-orm'

class User < CouchbaseOrm::Base
  has_many :tickets

  attribute :whatsapp_number, :string
  attribute :name, :string
  attribute :created_at, :datetime, default: -> { Time.now }
  attribute :updated_at, :datetime, default: -> { Time.now }

  validates :whatsapp_number, presence: true
  validates :name, presence: true

  before_save :set_timestamps

  private

  def set_timestamps
    self.updated_at = Time.now
  end

  def self.find_or_create_user_by_whatsapp_number(whatsapp_number)
    user = User.find_by(whatsapp_number: whatsapp_number)
    unless user
      user = User.create!(whatsapp_number: whatsapp_number, name: "User #{whatsapp_number[-4..-1]}")
    end
    user
  end
end
