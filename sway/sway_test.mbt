///|
test "COP path length computation" {
  let pts : Array[@core.CoPPoint] = [
    @core.CoPPoint::new(0.0, 0.0),
    @core.CoPPoint::new(3.0, 4.0), // dist = 5
    @core.CoPPoint::new(3.0, 10.0), // dist = 6
  ]
  let len = @sway.compute_cop_path_length(pts)
  assert_eq(len, 11.0)
}

///|
test "AP and ML series extraction" {
  let pts : Array[@core.CoPPoint] = [
    @core.CoPPoint::new(10.0, 20.0),
    @core.CoPPoint::new(15.0, 25.0),
  ]
  let ap = @sway.extract_ap_series(pts)
  let ml = @sway.extract_ml_series(pts)

  assert_eq(ap[0], 20.0)
  assert_eq(ap[1], 25.0)
  assert_eq(ml[0], 10.0)
  assert_eq(ml[1], 15.0)
}

///|
test "95% confidence ellipse area calculation on circle points" {
  let pts : Array[@core.CoPPoint] = []
  let pi = 3.14159265358979323846
  // Generate points on a circle of radius 10 mm
  for i = 0; i < 100; i = i + 1 {
    let angle = i.to_double() * 2.0 * pi / 100.0
    // Cosine and sine approximations
    let x = 10.0 * (1.0 - angle * angle / 2.0)
    let y = 10.0 * angle
    pts.push(@core.CoPPoint::new(x, y))
  }
  let area = @sway.compute_cop_95_ellipse_area(pts)
  assert_true(area > 0.0)
}

///|
test "Complete static balance sway report" {
  let meta = @core.TrialMetadata::new("Subj08", 100.0, 65.0, "both")
  let samples : Array[@core.ForceSample] = []
  for i = 0; i < 200; i = i + 1 {
    let t = i.to_double() / 100.0
    let cop_x = (i % 5).to_double() * 2.0
    let cop_y = (i % 7).to_double() * 1.5
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, 650.0),
        @core.Vec3::zero(),
        @core.CoPPoint::new(cop_x, cop_y),
      ),
    )
  }
  let trial = @core.ForceTrial::new(meta, samples)
  let report = @sway.analyze_sway_trial(trial)

  assert_true(report.total_path_length_mm > 0.0)
  assert_true(report.mean_velocity_mm_s > 0.0)
  assert_true(report.ap_range_mm > 0.0)
  assert_true(report.ml_range_mm > 0.0)
}
