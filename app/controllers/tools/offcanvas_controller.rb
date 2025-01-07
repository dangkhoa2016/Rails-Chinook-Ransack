module Tools
	class OffcanvasController < ApplicationController
		def display_settings
			mode = params[:mode].presence || 'card'
			@model = params[:model].presence || ''
			render partial: 'shared/display_settings', locals: { mode: mode }
		end
	end
end
