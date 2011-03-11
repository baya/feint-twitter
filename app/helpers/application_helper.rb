# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  module Auth

    def self.included(app)
      app.send(:helper_method, :current_user)
    end

    private

    def current_user
      @current_user ||= login_from_session
    end

    def login_from_session
      User.find(session[:user_id]) unless session[:user_id].blank?
    end

    def login_required
      if current_user.blank?
        redirect_to new_session_path
        store_location
      end
    end

    def store_location
      session[:forward] = request.url
    end

    def forward_or_redirect_to(default)
      redirect_to(session[:forward] || default)
      session[:forward] = nil
    end

    def authenticated?(user, password)
      user.password == Digest::MD5.hexdigest(password)
    end

  end

end
