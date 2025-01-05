module ApplicationHelper
  include Sortable
  include Pagy::Frontend

  PAGE_SIZES = [10, 15, 16, 20, 24, 25, 30, 36, 50, 100]
end
