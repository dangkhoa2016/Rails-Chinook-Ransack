module Tools
	class FiltersController < ApplicationController
		def index

			# sleep 10 if request.headers['HTTP_X_TURBO_REQUEST_ID'].present?
			# if rand(1..10) > 5
			# 	raise 'Error'
			# end

			filter_field = filter_params[:name]
			filter_template = filter_params[:template]
			if filter_field.blank? && filter_template.blank?
				return render plain: ''
			end

			@filter_params = filter_params

			render turbo_stream: turbo_stream.action_all('before', filter_params[:target], template: 'tools/filters/index')
		end

		def filter_params
			params.permit(:name, :model, :target, :template)
		end
	end
end
