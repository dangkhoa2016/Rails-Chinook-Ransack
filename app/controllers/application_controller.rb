class ApplicationController < ActionController::Base
  include Pagy::Backend
  before_action :set_locale, :set_page_size
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

  def set_page_size
    return unless params[:per_page].present?

    setting = params[:per_page].to_i
  
    # Default to Pagy::DEFAULT[:limit] if setting is invalid
    setting = Pagy::DEFAULT[:limit] if (setting.negative? || ApplicationHelper::PAGE_SIZES.exclude?(setting))

    cookies[:per_page] = { value: setting, expires: 1.year.from_now }
  end

  def render_500(exception)
    Rails.logger.error(exception.message)
    render file: Rails.root.join('public', '500.html'), status: 500, layout: false
  end
end
