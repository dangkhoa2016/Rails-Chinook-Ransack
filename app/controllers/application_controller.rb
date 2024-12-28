class ApplicationController < ActionController::Base
  include Pagy::Backend
  before_action :set_locale

  private

  def set_locale
    locale = params[:locale]&.strip
    return unless locale.present?

    locale = if locale && I18n.available_locales.include?(locale.to_sym)
      locale
    else
      cookies[:locale].presence || I18n.default_locale
    end
    I18n.locale = locale
    cookies[:locale] = { value: locale, expires: 1.year.from_now }
  end
end
