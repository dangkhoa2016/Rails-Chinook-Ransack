# Hướng Dẫn Thực Hiện Cải Tiến — Ưu Tiên Hàng Đầu

Danh sách này tập trung vào những gì **có thể làm ngay**, tác động cao, rủi ro thấp.

---

## Danh Sách Ưu Tiên

| # | Vấn đề | Mức độ | Thời gian ước tính |
|---|--------|--------|-------------------|
| 1 | SQL Injection trong `sort_column` | 🔴 Bảo mật | 30 phút |
| 2 | Raw SQL trong `sorting_params` của AlbumsController | 🔴 Bảo mật | 15 phút |
| 3 | `rescue => e` bắt tất cả exception | 🟡 Code quality | 30 phút |
| 4 | Giới hạn `per_page` parameter | 🟡 Bảo mật nhẹ | 15 phút |
| 5 | SQL Injection trong `artist_ids_with_most_albums` | 🔴 Bảo mật | 15 phút |
| 6 | Thêm composite indexes | 🟡 Performance | 20 phút |
| 7 | Thêm validations còn thiếu | 🟡 Data integrity | 30 phút |

---

## 1. Fix SQL Injection trong `sort_column`

**File**: `app/controllers/concerns/sortable.rb`

**Vấn đề**: `params[:sort]` được dùng trực tiếp để build ORDER BY clause mà không whitelist.
Kẻ tấn công có thể truyền vào `sort=id); DROP TABLE albums; --` hoặc dùng để đọc dữ liệu nhạy cảm.

**Code hiện tại**:
```ruby
def sort_column
  @sort_column ||= (params[:sort].presence || 'created_at').downcase
end
```

**Cách fix**: Thêm method `sortable_columns` để mỗi controller khai báo danh sách cột hợp lệ.

**Bước 1** — Sửa `app/controllers/concerns/sortable.rb`:
```ruby
module Sortable
  SORT_DIRECTIONS = %w[asc desc].freeze

  def sort_column
    @sort_column ||= begin
      requested = params[:sort].presence&.downcase || 'created_at'
      allowed = sortable_columns
      allowed.include?(requested) ? requested : 'created_at'
    end
  end

  # Override trong từng controller để khai báo cột được phép sort
  def sortable_columns
    []
  end

  def sort_direction
    @sort_direction ||= begin
      direction = params[:direction]&.downcase
      SORT_DIRECTIONS.include?(direction) ? direction : 'desc'
    end
  end

  def sort_direction_param(column)
    if is_current_sort_column?(column) && sort_direction == 'asc'
      'desc'
    else
      'asc'
    end
  end

  def is_current_sort_column?(column)
    sort_column == column.to_s.downcase
  end

  def sort_direction_asc?
    sort_direction == 'asc'
  end

  def sort_direction_desc?
    sort_direction == 'desc'
  end
end
```

**Bước 2** — Thêm `sortable_columns` vào từng controller (phần `private`):

`app/controllers/albums_controller.rb`:
```ruby
def sortable_columns
  %w[id title created_at updated_at tracks_count]
end
```

`app/controllers/artists_controller.rb`:
```ruby
def sortable_columns
  %w[id name created_at updated_at]
end
```

`app/controllers/tracks_controller.rb`:
```ruby
def sortable_columns
  %w[id name composer milliseconds unit_price created_at updated_at]
end
```

`app/controllers/customers_controller.rb`:
```ruby
def sortable_columns
  %w[id first_name last_name email company city country created_at updated_at]
end
```

`app/controllers/employees_controller.rb`:
```ruby
def sortable_columns
  %w[id first_name last_name title hire_date birth_date created_at updated_at]
end
```

`app/controllers/invoices_controller.rb`:
```ruby
def sortable_columns
  %w[id invoice_date billing_city billing_country total created_at updated_at]
end
```

`app/controllers/invoice_lines_controller.rb`:
```ruby
def sortable_columns
  %w[id unit_price quantity created_at updated_at]
end
```

`app/controllers/genres_controller.rb`:
```ruby
def sortable_columns
  %w[id name created_at updated_at]
end
```

`app/controllers/media_types_controller.rb`:
```ruby
def sortable_columns
  %w[id name created_at updated_at]
end
```

`app/controllers/playlists_controller.rb`:
```ruby
def sortable_columns
  %w[id name created_at updated_at]
end
```

`app/controllers/playlist_tracks_controller.rb`:
```ruby
def sortable_columns
  %w[id playlist_id track_id created_at updated_at]
end
```

---

## 2. Fix Raw SQL trong `sorting_params` của AlbumsController

**File**: `app/controllers/albums_controller.rb`

**Vấn đề**: `sort_direction` được nối thẳng vào string SQL.
```ruby
def sorting_params
  if is_sort_by_tracks_count?
    "COUNT(tracks.id) #{sort_direction}"  # ← nguy hiểm nếu sort_direction không được validate
  else
    super
  end
end
```

Mặc dù `sort_direction` đã được validate trong Sortable concern, nhưng nên dùng Arel để an toàn hơn và rõ ràng hơn.

**Cách fix**:
```ruby
def sorting_params
  if is_sort_by_tracks_count?
    direction = sort_direction == 'asc' ? :asc : :desc
    Arel.sql("COUNT(tracks.id) #{direction}")
  else
    super
  end
end
```

> **Lưu ý**: `Arel.sql()` là cách Rails khuyến nghị để đánh dấu rõ ràng rằng đây là SQL đã được kiểm soát, giúp tránh warning và rõ ý định hơn.

---

## 3. Fix `rescue => e` Bắt Tất Cả Exception

**File**: `app/controllers/albums_controller.rb` (và các controller khác có pattern tương tự)

**Vấn đề**: `rescue => e` bắt tất cả exception kể cả `NoMemoryError`, `SystemExit`... Ngoài ra logic xử lý `Pagy::OverflowError` bị lặp lại ở nhiều controller.

**Code hiện tại** (trong `albums_controller.rb`):
```ruby
def index
  begin
    @pagy, @albums = process_filters(model_query)
  rescue => e
    if e.is_a?(Pagy::OverflowError)
      @pagy = Pagy.new(count: 0)
      @albums = Album.none
    else
      raise e
    end
  end
  # ...
end
```

**Cách fix — Bước 1**: Xử lý `Pagy::OverflowError` tập trung tại `ApplicationController`:

`app/controllers/application_controller.rb`:
```ruby
class ApplicationController < ActionController::Base
  include Pagy::Backend
  before_action :set_locale, :set_page_size

  rescue_from Pagy::OverflowError, with: :handle_pagy_overflow
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from Exception, with: :render_500 if Rails.env.production?

  private

  def handle_pagy_overflow(exception)
    # Redirect về trang cuối cùng hợp lệ
    redirect_to url_for(page: exception.pagy.last), alert: I18n.t('errors.page_overflow', default: 'Page not found, redirected to last page.')
  end

  def handle_not_found(exception)
    respond_to do |format|
      format.html { redirect_to root_path, alert: I18n.t('errors.not_found', default: 'Record not found.') }
      format.json { render json: { error: exception.message }, status: :not_found }
    end
  end

  def set_locale
    locale = params[:locale]&.strip
    return unless locale.present?

    locale = if I18n.available_locales.include?(locale.to_sym)
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
    setting = Pagy::DEFAULT[:limit] if setting.negative? || ApplicationHelper::PAGE_SIZES.exclude?(setting)
    cookies[:per_page] = { value: setting, expires: 1.year.from_now }
  end

  def render_500(exception)
    Rails.logger.error(exception.message)
    render file: Rails.root.join('public', '500.html'), status: 500, layout: false
  end
end
```

**Cách fix — Bước 2**: Đơn giản hóa tất cả controller index action, xóa bỏ begin/rescue:

`app/controllers/albums_controller.rb`:
```ruby
def index
  @pagy, @albums = process_filters(model_query)

  if @albums.present?
    tracks_count = Track.count_by_model_ids(:album, @albums.pluck(:id))
    @albums.each { |album| album.tracks_count = tracks_count[album.id] || 0 }
  end

  render_index
end
```

Áp dụng tương tự cho tất cả controller còn lại có `begin/rescue` pattern.

---

## 4. Giới Hạn `per_page` Parameter

**File**: `app/controllers/application_controller.rb`

**Vấn đề**: Mặc dù `set_page_size` đã validate `per_page` với `PAGE_SIZES`, nhưng `PAGE_SIZES` có giá trị lên đến 100. Nếu sau này ai đó thêm giá trị lớn hơn vào `PAGE_SIZES` mà không nghĩ đến hậu quả, có thể gây load quá nhiều dữ liệu.

Thêm một hard limit tuyệt đối:

`app/helpers/application_helper.rb`:
```ruby
module ApplicationHelper
  include Sortable
  include Pagy::Frontend

  PAGE_SIZES = [10, 15, 16, 20, 24, 25, 30, 36, 50, 100].freeze
  MAX_PER_PAGE = 100
end
```

`app/controllers/application_controller.rb` — cập nhật `set_page_size`:
```ruby
def set_page_size
  return unless params[:per_page].present?

  setting = params[:per_page].to_i

  # Hard limit tuyệt đối, không phụ thuộc vào PAGE_SIZES
  if setting <= 0 || setting > ApplicationHelper::MAX_PER_PAGE || ApplicationHelper::PAGE_SIZES.exclude?(setting)
    setting = Pagy::DEFAULT[:limit]
  end

  cookies[:per_page] = { value: setting, expires: 1.year.from_now }
end
```

---

## 5. Fix SQL Injection trong `artist_ids_with_most_albums`

**File**: `app/models/album.rb`

**Vấn đề**: Giá trị `has_more_than_albums` được nối thẳng vào SQL string mà không dùng parameterized query.

**Code hiện tại**:
```ruby
def artist_ids_with_most_albums(has_more_than_albums = 5)
  Album.group(:artist_id).having("count_id >= #{has_more_than_albums}").order('count_id desc').count('id')
end

def artist_ids_with_fewest_albums(has_less_than_albums = 5)
  Album.group(:artist_id).having("count_id <= #{has_less_than_albums}").order('count_id desc').count('id')
end

def album_ids_with_most_tracks(has_more_than_tracks = 5)
  Album.joins(:tracks).group('albums.id').having("count_tracks_id >= #{has_more_than_tracks}").order('count_tracks_id desc').count('tracks.id')
end

def album_ids_with_fewest_tracks(has_less_than_tracks = 5)
  Album.joins(:tracks).group('albums.id').having("count_tracks_id <= #{has_less_than_tracks}").order('count_tracks_id desc').count('tracks.id')
end
```

**Cách fix** — dùng parameterized query với `?`:
```ruby
def artist_ids_with_most_albums(has_more_than_albums = 5)
  Album.group(:artist_id)
       .having('COUNT(id) >= ?', has_more_than_albums.to_i)
       .order('COUNT(id) DESC')
       .count('id')
end

def artist_ids_with_fewest_albums(has_less_than_albums = 5)
  Album.group(:artist_id)
       .having('COUNT(id) <= ?', has_less_than_albums.to_i)
       .order('COUNT(id) DESC')
       .count('id')
end

def album_ids_with_most_tracks(has_more_than_tracks = 5)
  Album.joins(:tracks)
       .group('albums.id')
       .having('COUNT(tracks.id) >= ?', has_more_than_tracks.to_i)
       .order('COUNT(tracks.id) DESC')
       .count('tracks.id')
end

def album_ids_with_fewest_tracks(has_less_than_tracks = 5)
  Album.joins(:tracks)
       .group('albums.id')
       .having('COUNT(tracks.id) <= ?', has_less_than_tracks.to_i)
       .order('COUNT(tracks.id) DESC')
       .count('tracks.id')
end
```

> **Lưu ý thêm**: Các alias column như `count_id`, `count_tracks_id` trong HAVING clause của code gốc có vẻ không đúng với SQLite — SQLite không hỗ trợ alias trong HAVING. Fix trên dùng aggregate function trực tiếp là cách đúng.

---

## 6. Thêm Composite Indexes

**Vấn đề**: Các query phổ biến như filter theo `customer_id + invoice_date`, hay sort theo `album_id + genre_id` không có index tổ hợp, dẫn đến full table scan.

**Tạo migration**:
```bash
rails generate migration AddCompositeIndexes
```

Nội dung file migration:
```ruby
class AddCompositeIndexes < ActiveRecord::Migration[7.1]
  def change
    # Invoices: thường filter/sort theo customer + date
    add_index :invoices, [:customer_id, :invoice_date], if_not_exists: true
    add_index :invoices, [:customer_id, :total], if_not_exists: true

    # Tracks: thường filter theo album + genre
    add_index :tracks, [:album_id, :genre_id], if_not_exists: true
    add_index :tracks, [:album_id, :media_type_id], if_not_exists: true

    # InvoiceLines: thường query theo invoice + track
    add_index :invoice_lines, [:invoice_id, :track_id], if_not_exists: true

    # Albums: thường query theo artist + thời gian
    add_index :albums, [:artist_id, :created_at], if_not_exists: true

    # PlaylistTracks: thường query theo playlist + track
    add_index :playlist_tracks, [:playlist_id, :track_id], if_not_exists: true

    # Employees: hierarchy query
    add_index :employees, [:reports_to, :hire_date], if_not_exists: true
  end
end
```

Chạy migration:
```bash
rails db:migrate
```

---

## 7. Thêm Validations Còn Thiếu

### 7a. PlaylistTrack — không có validation nào

**File**: `app/models/playlist_track.rb`

```ruby
class PlaylistTrack < ApplicationRecord
  belongs_to :playlist
  belongs_to :track

  # Thêm vào
  validates :playlist_id, presence: true
  validates :track_id, presence: true
  validates :track_id, uniqueness: {
    scope: :playlist_id,
    message: "already exists in this playlist"
  }

  # ... phần còn lại giữ nguyên
end
```

### 7b. Album — thiếu validate `artist_id`

**File**: `app/models/album.rb`

Code hiện tại chỉ có:
```ruby
validates :title, presence: true
```

Thêm vào:
```ruby
validates :title, presence: true, length: { maximum: 160 }
validates :artist_id, presence: true  # belongs_to đã validate nhưng thêm cho rõ ràng
```

> **Lưu ý**: Từ Rails 5+, `belongs_to` mặc định đã validate presence của foreign key. Nhưng thêm explicit validation giúp error message rõ ràng hơn.

### 7c. Kiểm tra các model khác

Chạy lệnh này để xem model nào thiếu validation:
```bash
rails runner "
[Album, Artist, Track, Genre, MediaType, Customer, Employee, Invoice, InvoiceLine, Playlist, PlaylistTrack].each do |model|
  validators = model.validators.map(&:class).uniq
  puts \"#{model}: #{validators.map(&:name).join(', ')}\"
end
"
```

---

## Thứ Tự Thực Hiện Đề Xuất

```
Ngày 1 (bảo mật — ~1.5 giờ):
  ✅ Mục 1: Fix sort_column whitelist
  ✅ Mục 2: Fix raw SQL trong sorting_params
  ✅ Mục 5: Fix SQL injection trong album model methods

Ngày 2 (code quality — ~1 giờ):
  ✅ Mục 3: Refactor rescue/exception handling
  ✅ Mục 4: Giới hạn per_page

Ngày 3 (data & performance — ~1 giờ):
  ✅ Mục 6: Thêm composite indexes
  ✅ Mục 7: Thêm validations
```

---

## Kiểm Tra Sau Khi Thực Hiện

```bash
# Khởi động server và test thủ công
bin/dev

# Test sort injection
curl "http://localhost:3000/albums?sort=id);DROP TABLE albums;--"
# Kỳ vọng: fallback về sort created_at, không crash

# Test per_page injection
curl "http://localhost:3000/albums?per_page=99999"
# Kỳ vọng: fallback về default page size

# Test page overflow
curl "http://localhost:3000/albums?page=99999"
# Kỳ vọng: redirect về trang cuối, không crash

# Kiểm tra indexes đã được tạo
rails dbconsole
> .schema invoices   -- xem indexes trên bảng invoices
```
