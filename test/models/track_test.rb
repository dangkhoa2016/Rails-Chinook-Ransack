require "test_helper"

class TrackTest < ActiveSupport::TestCase
  # --- Validations ---
  test "valid with all required fields" do
    assert tracks(:enter_sandman).valid?
  end

  test "invalid without name" do
    track = tracks(:enter_sandman)
    track.name = nil
    assert_not track.valid?
    assert_includes track.errors[:name], "can't be blank"
  end

  test "invalid without composer" do
    track = tracks(:enter_sandman)
    track.composer = nil
    assert_not track.valid?
  end

  test "invalid without milliseconds" do
    track = tracks(:enter_sandman)
    track.milliseconds = nil
    assert_not track.valid?
  end

  test "invalid without unit_price" do
    track = tracks(:enter_sandman)
    track.unit_price = nil
    assert_not track.valid?
  end

  # --- Associations ---
  test "belongs to album" do
    assert_equal albums(:black_album), tracks(:enter_sandman).album
  end

  test "belongs to genre" do
    assert_equal genres(:metal), tracks(:enter_sandman).genre
  end

  test "belongs to media_type" do
    assert_equal media_types(:mpeg), tracks(:enter_sandman).media_type
  end

  test "has one artist through album" do
    assert_equal artists(:metallica), tracks(:enter_sandman).artist
  end

  # --- Scopes ---
  test "has_invoices returns tracks with invoice lines" do
    result = Track.has_invoices(true)
    assert_includes result, tracks(:enter_sandman)
    assert_not_includes result, tracks(:back_in_black_track)
  end

  test "has_invoices false returns tracks without invoice lines" do
    result = Track.has_invoices(false)
    assert_includes result, tracks(:back_in_black_track)
    assert_not_includes result, tracks(:enter_sandman)
  end

  test "has_composers returns tracks with composer" do
    result = Track.has_composers(true)
    assert_includes result, tracks(:enter_sandman)
  end

  # --- Class methods ---
  test "count_by_model_ids returns correct counts" do
    album_id = albums(:black_album).id
    result = Track.count_by_model_ids(:album, [album_id])
    assert_equal 2, result[album_id]
  end

  test "count_invoice_lines_by_ids returns correct counts" do
    track_id = tracks(:enter_sandman).id
    result = Track.count_invoice_lines_by_ids([track_id])
    assert_equal 1, result[track_id]
  end

  # --- display_invoice_lines_count ---
  test "display_invoice_lines_count uses attr_accessor when set" do
    track = tracks(:enter_sandman)
    track.invoice_lines_count = 99
    assert_equal 99, track.display_invoice_lines_count
  end

  # --- to_s ---
  test "to_s returns name" do
    assert_equal "Enter Sandman", tracks(:enter_sandman).to_s
  end
end
