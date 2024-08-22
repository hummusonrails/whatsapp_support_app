require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  render_views

  describe 'GET #index' do
    let(:mock_user) { instance_double(User, name: 'Test User') }
    let(:mock_ticket) do
      instance_double(
        Ticket,
        id: 'ticket_id',
        query: 'Help!',
        status: 'open',
        created_at: Time.now,
        embedding: [],
        to_key: ['ticket_id'],
        model_name: Ticket.model_name,
        user: mock_user
      )
    end

    before do
      allow(Ticket).to receive(:where).and_return([mock_ticket])
      get :index
    end

    it 'renders the index template' do
      puts response.status
      expect(response).to have_http_status(:ok)
    end

    it 'displays the ticket' do
      expect(response.body).to include(mock_ticket.query)
    end
  end

  describe 'GET #show' do
    let(:mock_user) { instance_double(User, name: 'Test User', id: 2) }
    let(:mock_ticket) { instance_double(Ticket, id: 'ticket_id', query: 'Help!', user: mock_user, embedding: []) }

    before do
      allow(Ticket).to receive(:find).and_return(mock_ticket)
      allow(controller).to receive(:search_similar_tickets).and_return([])
      get :show, params: { id: 'ticket_id' }
    end

    it 'responds with a 200 status' do
      expect(response).to have_http_status(:ok)
    end

    it 'displays the ticket query and user name' do
      expect(response.body).to include(mock_ticket.query)
      expect(response.body).to include(mock_user.name)
    end
  end
end
