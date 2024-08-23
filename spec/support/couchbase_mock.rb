module CouchbaseMock
  def self.included(base)
    base.before do
      mock_couchbase_methods
    end
  end

  def mock_couchbase_methods
    allow(Couchbase::Cluster).to receive(:new).and_return(mock_cluster)
    allow(Couchbase::Cluster).to receive(:connect).and_return(mock_cluster)
    allow(mock_cluster).to receive(:disconnect)
    allow(mock_cluster).to receive(:bucket).and_return(mock_bucket)
    allow(Couchbase::Bucket).to receive(:new).and_return(mock_bucket)
    allow(Couchbase::Collection).to receive(:new).and_return(mock_collection)
    allow(mock_bucket).to receive(:default_collection).and_return(mock_collection)
  end

  def mock_cluster
    @mock_cluster ||= instance_double(Couchbase::Cluster)
  end

  def mock_bucket
    @mock_bucket ||= instance_double(Couchbase::Bucket)
  end

  def mock_collection
    @mock_collection ||= instance_double(Couchbase::Collection)
  end
end
