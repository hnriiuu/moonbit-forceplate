///|
test "Trapezoidal and Simpson integration of linear function" {
  let ts : Array[Double] = [0.0, 0.5, 1.0, 1.5, 2.0]
  let ys : Array[Double] = [0.0, 1.0, 2.0, 3.0, 4.0]

  let trap = @kinetic.integrate_trapezoidal(ts, ys, 0, 5)
  let simp = @kinetic.integrate_simpson(ts, ys, 0, 5)

  assert_true((trap - 4.0).abs() < 0.0001)
  assert_true((simp - 4.0).abs() < 0.0001)
}

///|
test "Estimate body mass from quiet standing" {
  let fz : Array[Double] = [686.4655, 686.4655, 686.4655, 686.4655]
  let mass = @kinetic.estimate_body_mass(fz, 0, 4)
  assert_true((mass - 70.0).abs() < 0.001)
}

///|
test "Compute kinematics from constant force" {
  let meta = @core.TrialMetadata::new("Subj04", 100.0, 70.0, "both")
  let samples : Array[@core.ForceSample] = []
  let bw_n = 70.0 * 9.80665
  for i = 0; i < 100; i = i + 1 {
    let t = i.to_double() / 100.0
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, bw_n + 200.0),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
  }
  let trial = @core.ForceTrial::new(meta, samples)
  let wf = @kinetic.compute_kinematics_from_trial(trial, 70.0)

  assert_eq(wf.acceleration.length(), 100)
  assert_true((wf.acceleration[50] - 2.857).abs() < 0.01)
  assert_true(wf.velocity[99] > 0.0)
}

///|
test "Impulse metrics calculation" {
  let ts : Array[Double] = [0.0, 0.1, 0.2, 0.3, 0.4]
  let fz : Array[Double] = [700.0, 800.0, 900.0, 1000.0, 700.0]
  let imp = @kinetic.calculate_impulse(ts, fz, 70.0, 0, 5)
  assert_true(imp.total_impulse > 0.0)
}

///|
test "RFD calculation on linear force ramp" {
  let ts : Array[Double] = [0.0, 0.05, 0.10, 0.15, 0.20]
  let fz : Array[Double] = [0.0, 250.0, 500.0, 750.0, 1000.0]
  let rfd = @kinetic.calculate_rfd_metrics(ts, fz, 0)

  assert_true((rfd.peak_rfd - 5000.0).abs() < 10.0)
  assert_true((rfd.rfd_0_100ms - 5000.0).abs() < 10.0)
}

///|
test "Mechanical work and energy metrics calculation" {
  let meta = @core.TrialMetadata::new("Subj04", 100.0, 70.0, "both")
  let samples : Array[@core.ForceSample] = []
  let bw_n = 70.0 * 9.80665
  for i = 0; i < 50; i = i + 1 {
    let t = i.to_double() / 100.0
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, bw_n + 300.0),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
  }
  let trial = @core.ForceTrial::new(meta, samples)
  let wf = @kinetic.compute_kinematics_from_trial(trial, 70.0)
  let work = @kinetic.calculate_mechanical_work(wf, 70.0)

  assert_true(work.concentric_work_j > 0.0)
  assert_true(work.peak_kinetic_energy_j > 0.0)
}
