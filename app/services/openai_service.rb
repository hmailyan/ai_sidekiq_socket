require 'openai'

class OpenaiService
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
end
