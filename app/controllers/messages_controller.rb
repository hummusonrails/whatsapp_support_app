class MessagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def inbound
    whatsapp_number = params[:from]
    text = params[:text]

    user = User.find_or_create_user_by_whatsapp_number(whatsapp_number)

    ticket = user.tickets.find_or_create_by(status: :open) do |ticket|
      ticket.query = text
      ticket.status = :open
    end

    send_message(
      to: whatsapp_number,
      text: "Thank you for your message. Please describe your support query."
    )

    ActionCable.server.broadcast "whatsapp_messages_#{user.id}", render_to_string(partial: "messages/reply", locals: { reply: text, sender: "User", ticket: ticket })

    head :ok
  end

  def reply
    ticket_id = params[:ticket_id]
    message = params[:message]

    ticket = Ticket.find(ticket_id)
    user = ticket.user

    reply = { sender: 'Agent', body: message, created_at: Time.current }

    ActionCable.server.broadcast "whatsapp_messages_#{user.id}", render_to_string(partial: "messages/reply", locals: { reply: message, sender: "Agent", ticket: ticket })

    if params[:mark_as_answer].present?
      ticket.update!(summary: message, status: :resolved, answer: message)
    end

    send_message(
      to: user.whatsapp_number,
      text: "Your query has been resolved. Summary: #{message}"
    )

    render json: { status: 'reply sent' }, status: :ok
  end

  def status
    head :ok
  end

  private

  def send_message(to:, text:)
    message = Vonage::Messaging::Message.whatsapp(
      type: 'text',
      message: text
    )

    response = VONAGE_CLIENT.messaging.send(
      from: ENV['VONAGE_WHATSAPP_NUMBER'],
      to: to,
      **message
    )

    puts "Message sent: #{response}"
  end
end
