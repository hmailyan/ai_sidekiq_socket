class MessagesController < ApplicationController
  before_action :set_message, only: %i[ show edit update destroy ai_generate ai_chat ]

  # GET /messages or /messages.json
  def index
    @messages = Message.all
  end

  # GET /messages/1 or /messages/1.json
  def show
  end

  # GET /messages/new
  def new
    @message = Message.new
  end

  # GET /messages/1/edit
  def edit
    @temp_name = nil 
  end

  def ai_generate
    @message
    DefaultJob.perform_async('send_ai', {message_id: @message.id, name: @message.name, ai_message: params[:ai_message]}.to_json)
    respond_to do |format|
      format.turbo_stream
    end
  end

  def ai_chat
    # Enqueue the background worker
    DefaultJob.perform_async('chat_ai', { input: params[:input], message_id: @message.id, name: @message.name }.to_json)
    respond_to do |format|
      format.turbo_stream
    end
  end
  # POST /messages or /messages.json
  def create
    @message = Message.new(message_params)

    respond_to do |format|
      if @message.save
        format.html { redirect_to message_url(@message), notice: "Message was successfully created." }
        format.json { render :show, status: :created, location: @message }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  def chat
    @chat_info = []
    @chat_uuid = SecureRandom.uuid
  end

  def answer
    p chat_params
    p 2222222222
    @chat_info = chat_params[:chat_info].present? ? JSON.parse(chat_params[:chat_info]) : [] 
    DefaultJob.perform_async('chat_ai', { chat_info: @chat_info, text: chat_params[:text]}.to_json)
  end

  # PATCH/PUT /messages/1 or /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to message_url(@message), notice: "Message was successfully updated." }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1 or /messages/1.json
  def destroy
    @message.destroy!

    respond_to do |format|
      format.html { redirect_to messages_url, notice: "Message was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    def chat_params
      params.permit(:text,:chat_info)
    end

    # Only allow a list of trusted parameters through.
    def message_params
      params.require(:message).permit(:name)
    end
end
