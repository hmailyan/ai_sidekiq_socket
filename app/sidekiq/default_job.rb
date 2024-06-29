class DefaultJob
  include Sidekiq::Job

  def perform(job,options = {})
    p "START"
    p job
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
      p 111111111111111111111
      openai_service = OpenaiService.new
      p options[:text]
      chat_info = openai_service.generate_json(options).map(&:deep_symbolize_keys)
      # p chat_info
      p options[:chat_uuid]
      Turbo::StreamsChannel.broadcast_replace_to(
        "chat_channel_#{options[:chat_uuid]}",
        target: "chat",
        partial: "messages/chat_cart",
        locals: { chat_info: chat_info, chat_uuid: options[:chat_uuid] }
      )
    end


    # Do something
  end
end
