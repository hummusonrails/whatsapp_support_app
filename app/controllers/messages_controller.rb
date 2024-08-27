class MessagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def inbound
    whatsapp_number = params[:from]
    text = params[:text]
    @reply = { sender: 'User', body: text, created_at: Time.current }
    @user = User.find_by(whatsapp_number: whatsapp_number)

    ActionCable.server.broadcast "messages_#{@user.id}", { reply: @reply, ticket: nil }

    if @user.nil?
      @user = User.create!(whatsapp_number: whatsapp_number, name: "User #{whatsapp_number[-4..-1]}")
      send_message(to: whatsapp_number, text: "Thank you for your message. Please describe your support query.")
      Ticket.create!(user_id: @user.id, query: text, status: Ticket::OPEN)
    else
      open_ticket = Ticket.find_by(user_id: @user.id, status: Ticket::OPEN)
    end

    if open_ticket.nil?
      Ticket.create!(user_id: @user.id, query: text, status: Ticket::OPEN)
    end

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.append("messages_#{@user.id}", partial: "messages/reply", locals: { reply: @reply }) }
    end
  end

  def reply
    @ticket_id = params[:ticket_id]
    @message = params[:message]
    @resolved = params[:mark_as_resolved] == "1"

    @ticket = Ticket.find(@ticket_id)
    @user = @ticket.user

    @reply = { sender: 'Agent', body: @message, created_at: Time.current }

    ActionCable.server.broadcast "messages_#{@user.id}", { reply: @reply, ticket: @ticket }

    if @resolved
      embedding = OPENAI_CLIENT.embeddings(
        parameters: {
          model: "text-embedding-ada-002",
          input: @message
        }
      )['data'][0]['embedding']

      @ticket.update!(summary: @message, status: Ticket::RESOLVED, embedding: embedding)

      respond_to do |format|
        format.html { redirect_to request.referrer, notice: "Ticket marked as resolved." }
      end
    else
      send_message(
        to: @user.whatsapp_number,
        text: @message
      )

      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.append("messages_#{@user.id}", partial: "messages/reply", locals: { reply: @reply }) }
      end
    end
  end

  def status
    head :ok
  end

  private

  # Using the Vonage Messages API Sandbox to send messages
  # Once you have a verified WhatsApp business account, you can use the Vonage Messages API
  # to send messages, and use the methods inside the Vonage Ruby SDK directly.
  def send_message(to:, text:)
    require 'net/http'
    require 'uri'
    require 'json'

    uri = URI.parse("https://messages-sandbox.nexmo.com/v1/messages")

    request = Net::HTTP::Post.new(uri)
    request.basic_auth(ENV['VONAGE_API_KEY'], ENV['VONAGE_API_SECRET'])
    request.content_type = 'application/json'
    request['Accept'] = 'application/json'

    request.body = {
      from: ENV['VONAGE_FROM_NUMBER'],
      to: to,
      message_type: 'text',
      text: text,
      channel: 'whatsapp'
    }.to_json

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    response = http.request(request)

    puts "Response Code: #{response.code}"
    puts "Response Body: #{response.body}"
  end
end
