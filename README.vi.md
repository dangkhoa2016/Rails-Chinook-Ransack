# Rails Chinook Ransack

> 🌐 Language / Ngôn ngữ: [English](README.md) | **Tiếng Việt**

Rails Chinook Ransack là ứng dụng Rails dùng bộ dữ liệu mẫu Chinook để minh họa một dashboard CRUD có tìm kiếm nâng cao, phân trang và phân quyền. Dự án kết hợp Ransack, Pagy, Devise, Pundit và giao diện Bootstrap/Hotwire để quản lý nhiều bảng dữ liệu trong cùng một ứng dụng.

## Tính năng chính

- Dashboard sau đăng nhập để tổng hợp nhanh các bảng Chinook chính và đi thẳng tới từng danh sách dữ liệu.
- CRUD cho các tài nguyên: albums, artists, customers, employees, genres, media types, playlists, playlist tracks, tracks, invoices và invoice lines.
- Tìm kiếm và lọc dữ liệu với Ransack, bao gồm text filter, range filter, boolean filter và remote select cho nhiều form.
- Phân trang với Pagy.
- Đăng nhập/đăng ký với Devise.
- Phân quyền với Pundit: admin có toàn quyền CRUD, user thông thường chỉ được xem dữ liệu.
- Bulk edit và bulk destroy cho nhiều tài nguyên thông qua khu vực `bulk_actions`.
- Giao diện dùng Bootstrap 5, Bootstrap Icons, Turbo, Stimulus, importmap và CSS bundling qua Sass/PostCSS.

## Công nghệ và phụ thuộc

- Ruby 3.4.7
- Rails 7.1.5
- SQLite3
- Node.js và Yarn
- Bootstrap 5 + Sass + PostCSS
- Ransack 4.2
- Pagy 9.3
- Devise 4.9
- Pundit 2.4

## Yêu cầu hệ thống

Cần cài sẵn các thành phần sau trên máy phát triển:

- Ruby 3.4.7
- Bundler
- SQLite3
- Node.js
- Yarn

## Cài đặt môi trường phát triển

Luồng cài đặt đề nghị:

```bash
bin/setup
yarn install
bin/rails db:seed
```

Trong đó:

- `bin/setup` sẽ cài gem, chuẩn bị database và dọn dẹp log/tmp.
- `yarn install` cài các gói frontend phục vụ build CSS.
- `bin/rails db:seed` nạp bộ dữ liệu Chinook và tạo tài khoản mặc định.

Nếu muốn khởi tạo lại dữ liệu từ đầu, có thể dùng:

```bash
bin/rails db:reset
bin/rails db:seed
```

## Cấu hình

Ứng dụng dùng SQLite với các file database mặc định:

- `storage/development.sqlite3`
- `storage/test.sqlite3`
- `storage/production.sqlite3`

File `env.sample` cung cấp một số biến môi trường tham khảo cho Puma và Rails như `RAILS_MAX_THREADS`, `RAILS_MIN_THREADS`, `WEB_CONCURRENCY` và `PORT`.

## Chạy ứng dụng

Cách chạy đề nghị trong môi trường development:

```bash
bin/dev
```

Lệnh này sử dụng `Procfile.dev` để khởi động:

- Rails server
- CSS watcher (`yarn watch:css`)

Mặc định `bin/dev` chạy ở cổng `3000`. Nếu muốn đổi cổng:

```bash
PORT=4000 bin/dev
```

Nếu đã build CSS trước đó và chỉ muốn chạy Rails server:

```bash
yarn build:css
bin/rails server
```

Route gốc của ứng dụng là `/`, health check có sẵn tại `/up`.

## Ảnh chụp màn hình

Xem [SCREENSHOTS.vi.md](SCREENSHOTS.vi.md) để có bộ ảnh minh họa giao diện hiện tại, bao gồm dashboard quản trị, các màn hình đăng nhập/đăng ký, danh sách dữ liệu, trang hồ sơ và sidebar bộ lọc.

## Tài khoản mặc định sau khi seed

Lệnh seed tạo sẵn 2 tài khoản:

- Admin: `admin@example.com` / `password123`
- User thường: `user@example.com` / `password123`

Tất cả màn hình trong ứng dụng đều yêu cầu đăng nhập. Theo chính sách hiện tại:

- Admin có quyền tạo, sửa, xóa và thực hiện bulk actions.
- User thường được phép xem danh sách, chi tiết và các JSON endpoint dùng cho select box.

## Kiểm thử

Dự án sử dụng Minitest, đồng thời đã cài đặt Capybara và Selenium cho system test.

Chạy toàn bộ test:

```bash
bin/rails test
```

## Dữ liệu và chức năng tìm kiếm

Bộ seed nạp dữ liệu Chinook cho các bảng chính như artist, album, employee, customer, genre, invoice, media type, playlist, track, playlist_track và invoice_line.

Phần tìm kiếm/lọc dữ liệu được tổ chức theo các service trong `app/services/search`, cho phép:

- cấu hình filter theo từng model,
- render filter động,
- phân tích giá trị query params,
- hỗ trợ remote select cho các trường liên kết.

Ngoài ra, namespace `tools` cung cấp các tiện ích liên quan đến bộ lọc, display settings và bulk edit UI.

## Frontend

Ứng dụng không dùng bundler JavaScript phức tạp. Frontend hiện tại được tổ chức theo hướng nhẹ:

- Importmap cho JavaScript module
- Turbo và Stimulus cho hành vi tương tác
- Bootstrap 5 và Bootstrap Icons cho giao diện
- Sass + PostCSS cho pipeline CSS

Script npm/yarn hiện có:

```bash
yarn build:css
yarn watch:css
```

## Dịch vụ bên ngoài

Dự án hiện không yêu cầu Redis, Sidekiq hay search engine riêng. Tìm kiếm được thực hiện trực tiếp bằng Active Record + Ransack trên SQLite.

## Ghi chú production

Ứng dụng hiện có cấu hình production cơ bản với Puma và SQLite. Nếu triển khai thực tế, bạn nên xem lại:

- secret và credentials,
- CSDL production phù hợp hơn SQLite,
- cấu hình web server/reverse proxy,
- chiến lược lưu trữ và backup dữ liệu.
