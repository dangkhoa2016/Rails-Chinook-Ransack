class ApplicationController < ActionController::Base
  include Pagy::Backend
  before_action :set_locale, :set_page_size

  rescue_from Pagy::OverflowError, with: :handle_pagy_overflow
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from Exception, with: :render_500 if Rails.env.production?

  private

  def handle_pagy_overflow(exception)
    redirect_to url_for(page: exception.pagy.last), alert: 'Page not found, redirected to last page.'
  end

  def handle_not_found(exception)
    respond_to do |format|
      format.html { redirect_to root_path, alert: 'Record not found.' }
      format.json { render json: { error: exception.message }, status: :not_found }
    end
  end

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

    # Hard limit: reject anything outside allowed list or above max
    if setting <= 0 || setting > ApplicationHelper::MAX_PER_PAGE || ApplicationHelper::PAGE_SIZES.exclude?(setting)
      setting = Pagy::DEFAULT[:limit]
    end

    cookies[:per_page] = { value: setting, expires: 1.year.from_now }
  end

  def render_500(exception)
    Rails.logger.error(exception.message)
    render file: Rails.root.join('public', '500.html'), status: 500, layout: false
  end
end
