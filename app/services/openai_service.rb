require 'openai'

class OpenaiService
  INIT_CHAT = [
          {role: "system", content: 'You are a chatbot creator. The chatbot usually aims to generate a lead for a service or product, persuade a user to purchase a product, or present a job to applicants and qualify them. You always respond in string format.
            You have a lively writing style and know how to express yourself excitingly. You can persuade people well to click through the chat until the end and submit their application. '
          }
        ]
  def initialize
    p ENV['OPENAI_API_KEY']
    p "-----------------------------------------------"
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
  end

  def complete(data)
    @client.chat(      
        parameters: {
            model: "gpt-4-turbo",
            messages: [
                {role: "system", content: "You are a text editor expert who make text like needed and return only text back"},
                {role: "user", content: "Text: #{data[:name]}, Need:#{data[:ai_message]}"}
            ]
        }
    )
  end

  def generate_json(data)
    if data[:chat_info].present?
      chat_info = data[:chat_info]
    else
      chat_info = INIT_CHAT
    end
    chat_info << {role: "user", content: "#{data[:text]}"}
    response = @client.chat(
      parameters: {
        model: "gpt-4-turbo",
        messages: chat_info
      }
    )
    chat_info << response['choices'].first['message']
  end

end
