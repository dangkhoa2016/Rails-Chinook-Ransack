class ApplicationController < ActionController::Base
  include Pagy::Backend
  before_action :set_locale
  rescue_from Exception, with: :render_500 if Rails.env.production?


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

  def render_500(exception)
    Rails.logger.error(exception.message)
    render file: Rails.root.join('public', '500.html'), status: 500, layout: false
  end
end
