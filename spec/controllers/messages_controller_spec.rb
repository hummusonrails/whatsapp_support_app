require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  let(:user) { double('User', id: 1, whatsapp_number: '1234567890') }
  let(:ticket) { double('Ticket', query: nil, status: nil) }
  let(:tickets) { double('tickets') }

  before do
    allow(User).to receive(:find_or_create_user_by_whatsapp_number).and_return(user)
    allow(user).to receive(:tickets).and_return(tickets)
    allow(tickets).to receive(:find_or_create_by).and_yield(ticket).and_return(ticket)
    allow(ticket).to receive(:query=).with('How do I reset my password?')
    allow(ticket).to receive(:status=).with(:open)
    allow(controller).to receive(:send_message)
    allow(ActionCable.server).to receive(:broadcast)
  end

  it 'creates a new ticket and sends a response' do
    post :inbound, params: { from: '1234567890', text: 'How do I reset my password?' }

    expect(user.tickets).to have_received(:find_or_create_by).with(status: :open)
    expect(ticket).to have_received(:query=).with('How do I reset my password?')
    expect(ticket).to have_received(:status=).with(:open)
    expect(controller).to have_received(:send_message).with(to: '1234567890', text: 'Thank you for your message. Please describe your support query.')
    expect(ActionCable.server).to have_received(:broadcast).with("whatsapp_messages_1", any_args)
    expect(response).to have_http_status(:ok)
  end

  describe 'POST #reply' do
    let(:mock_user) { double('User', whatsapp_number: '1234567890', id: 'user_id') }
    let(:mock_ticket) { double('Ticket', id: 'ticket_id', query: 'Help!', status: :open, user: mock_user) }

    before do
      allow(Ticket).to receive(:find).and_return(mock_ticket)
      allow(mock_ticket).to receive(:update!)

      allow(controller).to receive(:send_message).and_call_original
      mock_messaging = instance_double(Vonage::Messaging)
      allow(VONAGE_CLIENT).to receive(:messaging).and_return(mock_messaging)
      allow(mock_messaging).to receive(:send)

      post :reply, params: { ticket_id: 'ticket_id', message: 'Resolved!', mark_as_answer: true }
    end

    it 'updates the ticket and sends a reply' do
      expect(Ticket).to have_received(:find).with('ticket_id')
      expect(mock_ticket).to have_received(:update!).with(summary: 'Resolved!', status: :resolved, answer: 'Resolved!')
      expect(controller).to have_received(:send_message).with(to: '1234567890', text: 'Your query has been resolved. Summary: Resolved!')
      expect(VONAGE_CLIENT.messaging).to have_received(:send)
      expect(response).to have_http_status(:ok)
    end
  end
end
