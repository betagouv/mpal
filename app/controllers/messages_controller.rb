class MessagesController < ApplicationController
  before_action :assert_projet_courant

  def new
    render_new
  end

  def create
    @message = @projet_courant.messages.new(message_params)
    @message.auteur = author
    unless @message.save
      return render_new
    end
    redirect_to new_projet_or_dossier_message_path(@projet_courant)
  end

private
  def author
    if agent_signed_in?
      current_agent
    else
      @projet_courant.demandeur
    end
  end

  def message_params
    params.require(:message).permit(:corps_message)
  end

  def render_new
    @message = Message.new(projet: @projet_courant)
    @page_heading = "Messagerie"
  end
end

