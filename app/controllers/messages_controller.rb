class MessagesController < ApplicationController
  before_action :assert_projet_courant
  after_action  :mark_last_read_messages_at
  load_and_authorize_resource

  def new
    render_new
  end

  def create
    @message = @projet_courant.messages.new(message_params)
    @message.auteur = author
    unless @message.save
      return render_new
    end
    send_notification_to_demandeur
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

  def mark_last_read_messages_at
    if current_agent
      @projet_courant.mark_last_read_messages_at!(current_agent)
    elsif @projet_courant.demandeur
      @projet_courant.mark_last_read_messages_at!(@projet_courant.demandeur)
    end
  end

  def message_params
    params.require(:message).permit(:corps_message)
  end

  def render_new
    @projet_courant.reload
    @message = Message.new(projet: @projet_courant)
    @page_heading = "Messagerie"
    render :new
  end

  def send_notification_to_demandeur
    if @message.auteur != @projet_courant.demandeur
      MessageMailer.messagerie_instantanee(@projet_courant, @message).deliver_later!
    end
  end
end
