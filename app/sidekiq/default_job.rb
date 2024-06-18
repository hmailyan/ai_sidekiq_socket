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
      ["message_channel", message],
      target: "message_#{message.id}",
      partial: "messages/form",
      locals: { message: message }
    )


    # Do something
  end
end
