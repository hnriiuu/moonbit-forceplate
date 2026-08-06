///|
test "Movement onset detection with 5sd threshold" {
  let ts : Array[Double] = []
  let fz : Array[Double] = []
  for i = 0; i < 100; i = i + 1 {
    ts.push(i.to_double() / 1000.0)
    let noise = if i % 2 == 0 { 1.0 } else { -1.0 }
    fz.push(700.0 + noise)
  }
  for i = 100; i < 200; i = i + 1 {
    ts.push(i.to_double() / 1000.0)
    fz.push(400.0)
  }

  let onset_i = @event.detect_movement_onset_5sd(fz, 700.0, 1.0)
  assert_eq(onset_i, 100)
}

///|
test "Takeoff and landing detection" {
  let fz : Array[Double] = [
    700.0, 700.0, 500.0, 5.0, 0.0, 0.0, 8.0, 500.0, 1200.0,
  ]
  let takeoff_i = @event.detect_takeoff_index(fz, 0, 10.0)
  assert_eq(takeoff_i, 3)

  let landing_i = @event.detect_landing_index(fz, takeoff_i, 10.0)
  assert_eq(landing_i, 8)
}

///|
test "Min and peak force index finding" {
  let fz : Array[Double] = [700.0, 400.0, 300.0, 800.0, 1500.0, 1200.0]
  let min_i = @event.find_min_force_index(fz, 0, 6)
  let max_i = @event.find_peak_force_index(fz, 0, 6)

  assert_eq(min_i, 2)
  assert_eq(max_i, 4)
}

///|
test "Phase segmentation durations" {
  let ts : Array[Double] = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7]
  let fz : Array[Double] = [700.0, 500.0, 400.0, 800.0, 1200.0, 0.0, 0.0, 800.0]
  let events = @event.EventIndices::new(1, 0.1, 2, 0.2, 5, 0.5, 7, 0.7, 4, 0.4)
  let phases = @event.segment_jump_phases(ts, fz, events, 70.0)
  let durs = @event.compute_phase_durations(ts, phases)

  assert_true(durs.flight_duration > 0.15)
}
