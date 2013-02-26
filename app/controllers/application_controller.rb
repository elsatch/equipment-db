class ApplicationController < ActionController::Base
  protect_from_forgery

  def authenticate_user_with_local_exception
    return if request.remote_ip == '86.162.158.158'
    authenticate_user!
  end

  def require_authorized_user_with_local_exception
    return if request.remote_ip == '86.162.158.158'
    require_authorized_user
  end

  def require_authorized_user
    render :template => 'sessions/unauthorized', :status => 401 unless current_user.authorized?
  end
end
