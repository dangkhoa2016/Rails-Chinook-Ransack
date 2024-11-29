Album.count
Artist.count
Customer.count
Employee.count
Genre.count
Invoice.count
InvoiceLine.count
MediaType.count
Playlist.count
Track.count
PlaylistTrack.count

# test associations
# Album
al = Album.first
al.artist
al.tracks.count
al.genres.count
al.media_types.count
al.invoice_lines.count
al.invoices.count
al.customers.count
al.playlist_tracks.count
al.playlists.count
al.support_reps.count

# Artist
ar = Artist.first
ar.albums.count
ar.tracks.count
ar.genres.count
ar.media_types.count
ar.invoice_lines.count
ar.invoices.count
ar.customers.count
ar.playlist_tracks.count
ar.playlists.count
ar.support_reps.count

# Customer
cu = Customer.first
cu.support_rep
cu.invoices.count
cu.invoice_lines.count
cu.albums.count
cu.artists.count
cu.tracks.count
cu.genres.count
cu.media_types.count
cu.playlist_tracks.count
cu.playlists.count

# Employee
em = Employee.find(3)
em.customers.count
em.subordinates.count
em.reporting_to
em.invoices.count
em.invoice_lines.count
em.tracks.count
em.genres.count
em.media_types.count
em.playlist_tracks.count
em.playlists.count
em.albums.count
em.artists.count

# Genre
ge = Genre.first
ge.tracks.count
ge.albums.count
ge.artists.count
ge.media_types.count
ge.invoice_lines.count
ge.invoices.count
ge.customers.count
ge.playlist_tracks.count
ge.playlists.count
ge.support_reps.count

# InvoiceLine
il = InvoiceLine.first
il.track
il.invoice
il.customer
il.support_rep
il.album
il.artist
il.genre
il.media_type
il.playlist_tracks.count
il.playlists.count

# Invoice
inv = Invoice.first
inv.customer
inv.invoice_lines.count
inv.tracks.count
inv.playlist_tracks.count
inv.playlists.count
inv.genres.count
inv.media_types.count
inv.albums.count
inv.artists.count
inv.support_rep

# MediaType
me = MediaType.first
me.tracks.count
me.albums.count
me.artists.count
me.genres.count
me.invoice_lines.count
me.invoices.count
me.customers.count
me.playlist_tracks.count
me.playlists.count
me.support_reps.count

# PlaylistTrack
pt = PlaylistTrack.first
pt.playlist
pt.track
pt.genre
pt.media_type
pt.album
pt.artist
pt.invoice_lines.count
pt.invoices.count
pt.customers.count
pt.support_reps.count

# Playlist
pl = Playlist.first
pl.playlist_tracks.count
pl.tracks.count
pl.albums.count
pl.artists.count
pl.genres.count
pl.media_types.count
pl.invoice_lines.count
pl.invoices.count
pl.customers.count
pl.support_reps.count

# Track
tr = Track.first
tr.album
tr.media_type
tr.genre
tr.invoice_lines.count
tr.invoices.count
tr.playlist_tracks.count
tr.playlists.count
tr.customers.count
tr.artists.count
tr.support_reps.count
