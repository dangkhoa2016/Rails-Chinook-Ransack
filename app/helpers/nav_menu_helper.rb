module NavMenuHelper

  def get_url(menu)
    if menu.is_a?(String)
      if menu.start_with?('language_path_')
        language = menu.split('language_path_').pop
        return url_for({ locale: language }.merge(request.query_parameters))
      end
    end
    url = send(menu) rescue nil
    url.presence || '#'
  end

  def get_controller_name(url)
    url = url.to_s.split('/').last
    url = url.gsub(/_path/, '')
    url = nil if url == '#'
    url == 'root' ? 'home' : url
  end

  def is_menu_active(menu)
    current_controller = request.path_parameters[:controller]
    url = menu.is_a?(Hash) ? menu[:url] : menu
    controller_name = get_controller_name(url)
    is_active = controller_name.to_s == current_controller.to_s
    if is_active
      return true
    end

    if menu.is_a?(Hash) && menu[:children].present?
      return menu[:children].find { |key, value| is_menu_active(value) }
    else
      false
    end
  end

  def nav_menus
    {
      'nav.home': {
        url: 'root_path',
        icon: 'home'
      },
      'nav.music': {
        url: '#',
        icon: 'music-note-list',
        children: {
          'nav.albums': 'albums_path',
          'nav.artists': 'artists_path',
          'nav.genres': 'genres_path',
          'nav.media_types': 'media_types_path',
          'nav.tracks': 'tracks_path',
          'nav.playlists': 'playlists_path'
        }
      },
      'nav.store': {
        url: '#',
        icon: 'table',
        children: {
          'nav.invoices': 'invoices_path',
          'nav.invoice_lines': 'invoice_lines_path',
          'nav.employees': 'employees_path',
          'nav.customers': 'customers_path',
        }
      },
      'nav.languages': {
        url: '#',
        icon: 'translate',
        children: {
          'nav.vietnamese': 'language_path_vi',
          'nav.english': 'language_path_en',
        }
      },
      'nav.settings': {
        url: '#',
        icon: 'wrench-adjustable',
      }
    }
  end

end
