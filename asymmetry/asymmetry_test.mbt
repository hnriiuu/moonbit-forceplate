///|
test "Symmetry index, asymmetry ratio, and APD" {
  let l = 1000.0
  let r = 800.0
  let si = @asymmetry.calculate_symmetry_index(l, r)
  let ar = @asymmetry.calculate_asymmetry_ratio(l, r)
  let apd = @asymmetry.calculate_abs_percent_diff(l, r)

  assert_true((si - 22.22).abs() < 0.1)
  assert_eq(ar, 1.25)
  assert_eq(apd, 20.0)
}

///|
test "Dual plate bilateral trial analysis" {
  let meta_l = @core.TrialMetadata::new("Subj09", 1000.0, 70.0, "Left")
  let meta_r = @core.TrialMetadata::new("Subj09", 1000.0, 70.0, "Right")

  let samples_l : Array[@core.ForceSample] = []
  let samples_r : Array[@core.ForceSample] = []

  for i = 0; i < 200; i = i + 1 {
    let t = i.to_double() / 1000.0
    samples_l.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, 385.0),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
    samples_r.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, 315.0),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
  }

  let trial_l = @core.ForceTrial::new(meta_l, samples_l)
  let trial_r = @core.ForceTrial::new(meta_r, samples_r)

  let report = @asymmetry.analyze_dual_plate_trials(trial_l, trial_r, 70.0)

  assert_true((report.left_share_percent - 55.0).abs() < 0.1)
  assert_true((report.right_share_percent - 45.0).abs() < 0.1)
  assert_eq(report.dominant_side, "Left")
}

///|
test "Time-normalized asymmetry trajectory curve generation" {
  let meta_l = @core.TrialMetadata::new("Subj09", 1000.0, 70.0, "Left")
  let meta_r = @core.TrialMetadata::new("Subj09", 1000.0, 70.0, "Right")

  let samples_l : Array[@core.ForceSample] = []
  let samples_r : Array[@core.ForceSample] = []

  for i = 0; i < 100; i = i + 1 {
    let t = i.to_double() / 1000.0
    samples_l.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, 600.0),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
    samples_r.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, 400.0),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
  }

  let trial_l = @core.ForceTrial::new(meta_l, samples_l)
  let trial_r = @core.ForceTrial::new(meta_r, samples_r)

  let traj = @asymmetry.compute_asymmetry_trajectory(trial_l, trial_r)
  assert_eq(traj.asymmetry_index_curve.length(), 101)
  assert_true(traj.asymmetry_index_curve[50] > 30.0)
}
