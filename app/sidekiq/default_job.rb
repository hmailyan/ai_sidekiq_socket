class DefaultJob
  include Sidekiq::Job

  def perform(job,options = {})
    p "START"
    options = JSON.parse(options,:symbolize_names => true)
    p job
    p options

    openai_service = OpenaiService.new
    @response = openai_service.complete(options)
    if @response['choices'].first['message']['content']
      final_message = @response['choices'].first['message']['content']
    end
    p final_message
    message = Message.find(options[:message_id])
    message.name = final_message

    Turbo::StreamsChannel.broadcast_replace_to(
      "messages",
      target: "message_#{message.id}",
      partial: "messages/ai_message",
      locals: { message: message, temp_name: final_message }
    )


    # Do something
  end
end
