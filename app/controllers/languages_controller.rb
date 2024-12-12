class LanguagesController < ApplicationController
  def vietnamese
    I18n.locale = :vi
    redirect_back
  end

  def english
    I18n.locale = :en
    redirect_back
  end

  def redirect_back
    url = request.referer || root_path
    redirect_to url
  end
end
