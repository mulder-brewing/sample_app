module SessionsHelper
  #Log in the given user.
  def log_in(user)
    session[:user_id] = user.id
  end

  #Returns the current logged-in user (if any).
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?("remember",cookies.signed[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  #Retuens true if the given user is the current logged in user, false otherwise.
  def current_user?(user)
    user == current_user
  end

  #Returns true if the user is Logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end

  #Logs out the current user.
  def log_out
      forget(current_user)
      session.delete(:user_id)
      @current_user = nil
  end

  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent.signed[:remember_token] = user.remember_token
  end

  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Redirect to stored location (or to the default)
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  #Stores the URL trying to be accessed.
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
