class SocialController < ApplicationController
  before_action :authenticate_user!, except: [:overview, :locations, :discussion]
  before_action :set_active_top_nav_link_to_social

  def profile
    @social_profile = current_user.social_profile || current_user.create_social_profile

    session[:return_to] = request.referer if session.delete :return
  end

  def update_profile
    @social_profile = current_user.social_profile

    if @social_profile.update(social_profile_params)
      flash[:notice] = "Social profile successfully saved!"
      redirect_to(session[:return_to] ? session.delete(:return_to) : social_profile_path)
    else
      render :profile
    end
  end


  def locations
    if params[:show_user]
      @locations = SocialProfile.locations_for_map(current_user)
      @user_location = current_user.social_profile.location_for_map if current_user and current_user.social_profile and current_user.social_profile.show_location
    else
      @locations = SocialProfile.locations_for_map
    end

  end

  private

  def social_profile_params

    params.require(:social_profile).permit(
        :name,
        :show_location,
        :show_karma,
        :location,
        :latitude,
        :longitude,
        :location_id,
        :make_public,
        :age,
        :gender,
        :photo,
        :visible_to_community,
        :visible_to_world
    )
  end
end
