# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # Redirect to the previous page after a successful sign in
  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
