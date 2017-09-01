class SlackController < ApplicationController

  def commands
    ::Services::DispatchCommands.new(params: params).call
    ok
  end

  def interactive_messages
    ::Services::DispatchInteractiveMessages.new(params: JSON.parse(params[:payload])).call
  end

  private

  def ok
    render json: { text: "Processing requested: " + params[:text], response_type: "ephemeral", replace_original: true}
  end
end
