# Rails Chinook Ransack

> 🌐 Language / Ngôn ngữ: **English** | [Tiếng Việt](README.vi.md)

Rails Chinook Ransack is a Rails application that uses the Chinook sample dataset to demonstrate a CRUD dashboard with advanced search, pagination, and authorization. The project combines Ransack, Pagy, Devise, Pundit and a Bootstrap/Hotwire UI to manage multiple data tables within a single application.

## Main features

- Post-login dashboard that summarizes the main Chinook tables and links directly to each resource list.
- CRUD for resources: albums, artists, customers, employees, genres, media types, playlists, playlist tracks, tracks, invoices and invoice lines.  
- Search and filtering with Ransack, including text filters, range filters, boolean filters and remote select for many forms.  
- Pagination with Pagy.  
- Sign in / sign up with Devise.  
- Authorization with Pundit: admins have full CRUD rights, regular users can only view data.  
- Bulk edit and bulk destroy for many resources via the `bulk_actions` area.  
- UI uses Bootstrap 5, Bootstrap Icons, Turbo, Stimulus, importmap and CSS bundling via Sass/PostCSS.

## Technologies and dependencies

- Ruby 3.4.7  
- Rails 7.1.5  
- SQLite3  
- Node.js and Yarn  
- Bootstrap 5 + Sass + PostCSS  
- Ransack 4.2  
- Pagy 9.3  
- Devise 4.9  
- Pundit 2.4

## System requirements

The following components must be installed on the development machine:

- Ruby 3.4.7  
- Bundler  
- SQLite3  
- Node.js  
- Yarn

## Development setup

Recommended setup flow:

```bash
bin/setup
yarn install
bin/rails db:seed
```

Where:

- `bin/setup` installs gems, prepares the database and cleans logs/tmp.  
- `yarn install` installs frontend packages used to build CSS.  
- `bin/rails db:seed` loads the Chinook dataset and creates default accounts.

To reinitialize the data from scratch, you can use:

```bash
bin/rails db:reset
bin/rails db:seed
```

## Configuration

The app uses SQLite with default database files:

- `storage/development.sqlite3`  
- `storage/test.sqlite3`  
- `storage/production.sqlite3`

The `env.sample` file provides some example environment variables for Puma and Rails such as `RAILS_MAX_THREADS`, `RAILS_MIN_THREADS`, `WEB_CONCURRENCY` and `PORT`.

## Running the app

Recommended way to run in development:

```bash
bin/dev
```

This command uses `Procfile.dev` to start:

- Rails server  
- CSS watcher (`yarn watch:css`)

By default `bin/dev` runs on port `3000`. To change the port:

```bash
PORT=4000 bin/dev
```

If CSS has already been built and you only want to run the Rails server:

```bash
yarn build:css
bin/rails server
```

The app root route is `/`, health check is available at `/up`.

## Screenshots

See [SCREENSHOTS.md](SCREENSHOTS.md) for a visual walkthrough of the current UI, including the admin dashboard, authentication pages, resource index screens, profile management and filter sidebars.

## Default accounts after seeding

The seed script creates two accounts by default:

- Admin: `admin@example.com` / `password123`  
- Regular user: `user@example.com` / `password123`

All screens in the app require authentication. Under the current policy:

- Admins can create, edit, delete and perform bulk actions.  
- Regular users can view lists, details and the JSON endpoints used for select boxes.

## Testing

The project uses Minitest and includes Capybara and Selenium for system tests.

Run the full test suite:

```bash
bin/rails test
```

## Data and search functionality

The seed loads the Chinook dataset for main tables such as artist, album, employee, customer, genre, invoice, media type, playlist, track, playlist_track and invoice_line.

The search/filter functionality is organized into services under `app/services/search`, allowing:

- filter configuration per model,  
- dynamic filter rendering,  
- parsing of query param values,  
- support for remote select for association fields.

Additionally, the `tools` namespace provides utilities related to filters, display settings and the bulk edit UI.

## Frontend

The app avoids complex JavaScript bundlers. The frontend is organized in a lightweight way:

- Importmap for JavaScript modules  
- Turbo and Stimulus for interactive behavior  
- Bootstrap 5 and Bootstrap Icons for UI  
- Sass + PostCSS for the CSS pipeline

Available npm/yarn scripts:

```bash
yarn build:css
yarn watch:css
```

## External services

The project currently does not require Redis, Sidekiq or a separate search engine. Searching is performed directly with Active Record + Ransack on SQLite.

## Production notes

The app includes a basic production configuration with Puma and SQLite. For a real deployment, you should review:

- secrets and credentials,  
- a production database more suitable than SQLite,  
- web server / reverse proxy configuration,  
- data storage and backup strategy.
