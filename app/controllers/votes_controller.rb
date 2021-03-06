class VotesController < ApplicationController
  before_action :authenticate_user!

  before_action :set_research_topic,              only: [ :vote ]
  before_action :redirect_without_research_topic, only: [ :vote ]

  def vote
    if @research_topic and current_user.can_vote_for?(@research_topic) and current_user.has_votes_remaining?(params[:vote][:rating].to_i)
      @vote = Vote.find_or_initialize_by(user_id: current_user.id, research_topic_id: params[:vote][:research_topic_id])
      @vote.rating = params[:vote]["rating"]
      saved = @vote.save
    elsif params[:vote][:question_id]
      @vote = Vote.find_or_initialize_by(user_id: current_user.id, question_id: params[:vote][:question_id])
      @vote.rating = params[:vote]["rating"]
      saved = @vote.save
    end

    if @research_topic
      respond_to do |format|
        format.js
        format.json { render json: { saved: saved } }
      end
    else
      respond_to do |format|
        format.js { render nothing: true }
        format.json { head :no_content }
      end
    end

  end



  private

    def set_research_topic
      @research_topic = ResearchTopic.current.find_by_id(params[:vote] ? params[:vote][:research_topic_id] : nil)
    end

    def redirect_without_research_topic
      # empty_response_or_root_path(research_topics_path) unless @research_topic
    end

  # Never trust parameters from the scary internet, only allow the white list through.
  def object_params
    params.require(:vote).permit(:rating)
  end


end
