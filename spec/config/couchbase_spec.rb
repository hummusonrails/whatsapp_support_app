# spec/config/couchbase_spec.rb
require 'rails_helper'
require 'couchbase'

RSpec.describe 'Couchbase Configuration', type: :request do
  around do |example|
    original_env = {
      'COUCHBASE_CONNECTION_STRING' => ENV['COUCHBASE_CONNECTION_STRING'],
      'COUCHBASE_USERNAME' => ENV['COUCHBASE_USERNAME'],
      'COUCHBASE_PASSWORD' => ENV['COUCHBASE_PASSWORD'],
      'COUCHBASE_BUCKET' => ENV['COUCHBASE_BUCKET']
    }

    ENV['COUCHBASE_CONNECTION_STRING'] = 'couchbase://localhost'
    ENV['COUCHBASE_USERNAME'] = 'user'
    ENV['COUCHBASE_PASSWORD'] = 'password'
    ENV['COUCHBASE_BUCKET'] = 'bucket'

    example.run

    original_env.each { |key, value| ENV[key] = value }
  end

  let(:config) do
    {
      connection_string: ENV.fetch('COUCHBASE_CONNECTION_STRING'),
      username: ENV.fetch('COUCHBASE_USERNAME'),
      password: ENV.fetch('COUCHBASE_PASSWORD'),
      bucket: ENV.fetch('COUCHBASE_BUCKET')
    }
  end

  it 'should have a connection string' do
    expect(config[:connection_string]).not_to be_nil
  end

  it 'should have a username' do
    expect(config[:username]).not_to be_nil
  end

  it 'should have a password' do
    expect(config[:password]).not_to be_nil
  end

  it 'should have a bucket' do
    expect(config[:bucket]).not_to be_nil
  end

  it 'establishes a connection to Couchbase' do
    cluster = Couchbase::Cluster.connect(config[:connection_string], config[:username], config[:password])
    bucket = cluster.bucket(config[:bucket])

    allow(cluster).to receive(:disconnect)

    expect(bucket).to eq(mock_bucket)
    expect(cluster).to receive(:disconnect)
  ensure
    cluster.disconnect if cluster
  end
end
