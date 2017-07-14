class SlackController < ApplicationController

  def index
    @slack_url = ::Services::GetAuthUrl.new.call
  end

  def oauth_callback
    ::Services::SetToken.new(code: params[:code]).call
    ok
  end

  def commands
    ::Services::DispatchCommands.new(params: params).call
    ok
  end

  def interactive_messages
    ::Services::DispatchInteractiveMessages.new(params: JSON.parse(params[:payload])).call
    ok
  end

  private

  def ok
    render json: { text: "processing...", response_type: "ephemeral", replace_original: true }
  end
end