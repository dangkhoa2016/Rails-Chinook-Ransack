-- show all tables
SELECT name FROM sqlite_master WHERE type='table';

.mode table
.table


-- show number of albums records
select count(*) as number_of_albums from albums;

-- show number of tracks records
select count(*) as number_of_tracks from tracks;

-- show number of artists records
select count(*) as number_of_artists from artists;

-- show number of customers records
select count(*) as number_of_customers from customers;

-- show number of employees records
select count(*) as number_of_employees from employees;

-- show number of genres records
select count(*) as number_of_genres from genres;

-- show number of invoice records
select count(*) as number_of_invoices from invoices;

-- show number of media types records
select count(*) as number_of_media_types from media_types;

-- show number of playlist records
select count(*) as number_of_playlists from playlists;

-- show number of playlist track records
select count(*) as number_of_playlist_tracks from playlist_tracks;

-- show number of invoice lines records
select count(*) as number_of_invoice_lines from invoice_lines;

+------------------+
| number_of_albums |
+------------------+
| 347              |
+------------------+
+------------------+
| number_of_tracks |
+------------------+
| 3503             |
+------------------+
+-------------------+
| number_of_artists |
+-------------------+
| 275               |
+-------------------+
+---------------------+
| number_of_customers |
+---------------------+
| 59                  |
+---------------------+
+---------------------+
| number_of_employees |
+---------------------+
| 8                   |
+---------------------+
+------------------+
| number_of_genres |
+------------------+
| 25               |
+------------------+
+--------------------+
| number_of_invoices |
+--------------------+
| 412                |
+--------------------+
+-----------------------+
| number_of_media_types |
+-----------------------+
| 5                     |
+-----------------------+
+---------------------+
| number_of_playlists |
+---------------------+
| 18                  |
+---------------------+
+---------------------------+
| number_of_playlist_tracks |
+---------------------------+
| 8715                      |
+---------------------------+
+-------------------------+
| number_of_invoice_lines |
+-------------------------+
| 2240                    |
+-------------------------+


-- show all columns from the albums table
PRAGMA table_info(albums);

-- show all columns from the customers table
PRAGMA table_info(customers);

-- show all columns from the employees table
PRAGMA table_info(employees);

-- show all columns from the invoices table
PRAGMA table_info(invoices);


-- list all identities indexes
SELECT name, sql FROM sqlite_master WHERE type='index' AND tbl_name IN
 ('albums', 'artists', 'customers', 'employees', 'genres', 'invoices',
 'invoice_lines', 'media_types', 'playlists', 'playlists_tracks', 'tracks');

-- list all foreign keys
PRAGMA foreign_key_list(albums);
PRAGMA foreign_key_list(artists);
PRAGMA foreign_key_list(customers);
PRAGMA foreign_key_list(employees);
PRAGMA foreign_key_list(genres);
PRAGMA foreign_key_list(invoices);
PRAGMA foreign_key_list(invoice_lines);
PRAGMA foreign_key_list(media_types);
PRAGMA foreign_key_list(playlists);
PRAGMA foreign_key_list(playlists_tracks);
PRAGMA foreign_key_list(tracks);

-- get max id
SELECT MAX(id) FROM albums;
select MAX(id) from artists;
select MAX(id) from customers;
select MAX(id) from employees;
select MAX(id) from genres;
select MAX(id) from invoices;
select MAX(id) from invoice_lines;
select MAX(id) from media_types;
select MAX(id) from playlists;
select MAX(id) from playlist_tracks;
select MAX(id) from tracks;
