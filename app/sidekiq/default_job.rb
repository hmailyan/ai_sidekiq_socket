class DefaultJob
  include Sidekiq::Job

  def perform(job,options = {})
    p "START"
    p job
    p options
    options = JSON.parse(options,:symbolize_names => true)

    case job
    when 'send_ai'
      openai_service = OpenaiService.new
      @response = openai_service.complete(options)
      if @response['choices'].first['message']['content']
        final_message = @response['choices'].first['message']['content']
      end
      p final_message
      message = Message.find(options[:message_id])
      message.name = final_message

      Turbo::StreamsChannel.broadcast_replace_to(
        ["message_channel", message],
        target: "message_#{message.id}",
        partial: "messages/form",
        locals: { message: message }
      )
    when 'chat_ai'
      p 'chat_ai'

      openai_service = OpenaiService.new
      chat_info = openai_service.generate_json(options).map(&:deep_symbolize_keys)
      p chat_info
      
      Turbo::StreamsChannel.broadcast_replace_to(
        ["chat_channel", 2],
        target: "chat",
        partial: "messages/chat_cart",
        locals: { chat_info: chat_info }
      )
    end


    # Do something
  end
end
