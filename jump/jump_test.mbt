///|
test "CMJ complete analysis pipeline" {
  let meta = @core.TrialMetadata::new("Subj05", 1000.0, 70.0, "both")
  let samples : Array[@core.ForceSample] = []
  let bw_n = 70.0 * 9.80665

  // 100 samples quiet standing (700 N)
  for i = 0; i < 100; i = i + 1 {
    let t = i.to_double() / 1000.0
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, bw_n),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
  }
  // 100 samples unloading down to 400 N
  for i = 100; i < 200; i = i + 1 {
    let t = i.to_double() / 1000.0
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, 400.0),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
  }
  // 150 samples propulsive push up to 1600 N
  for i = 200; i < 350; i = i + 1 {
    let t = i.to_double() / 1000.0
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, 1600.0),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
  }
  // 400 samples flight phase (0 N)
  for i = 350; i < 750; i = i + 1 {
    let t = i.to_double() / 1000.0
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::zero(),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
  }
  // 100 samples landing impact (1800 N)
  for i = 750; i < 850; i = i + 1 {
    let t = i.to_double() / 1000.0
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, 1800.0),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
  }

  let trial = @core.ForceTrial::new(meta, samples)
  let report = @jump.analyze_cmj_trial(trial, 70.0)

  assert_true(report.jump_height_flight_m > 0.15)
  assert_true(report.peak_force_n > 1500.0)
  assert_true(report.rsi_modified > 0.0)
}

///|
test "Squat Jump analysis and dip detection" {
  let meta = @core.TrialMetadata::new("Subj06", 1000.0, 70.0, "both")
  let samples : Array[@core.ForceSample] = []
  let bw_n = 70.0 * 9.80665

  // Quiet standing then immediate push-off without unloading dip
  for i = 0; i < 100; i = i + 1 {
    let t = i.to_double() / 1000.0
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, bw_n),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
  }
  for i = 100; i < 300; i = i + 1 {
    let t = i.to_double() / 1000.0
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, 1500.0),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
  }
  for i = 300; i < 650; i = i + 1 {
    let t = i.to_double() / 1000.0
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::zero(),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
  }
  for i = 650; i < 750; i = i + 1 {
    let t = i.to_double() / 1000.0
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, 1500.0),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
  }

  let trial = @core.ForceTrial::new(meta, samples)
  let sj_report = @jump.analyze_sj_trial(trial, 70.0)

  assert_true(sj_report.jump_height_flight_m > 0.1)
  assert_false(sj_report.countermovement_dip_detected)
}

///|
test "Drop Jump RSI and stiffness analysis" {
  let meta = @core.TrialMetadata::new("Subj07", 1000.0, 70.0, "both")
  let samples : Array[@core.ForceSample] = []
  let bw_n = 70.0 * 9.80665

  // Initial quiet standing
  for i = 0; i < 100; i = i + 1 {
    let t = i.to_double() / 1000.0
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, bw_n),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
  }
  // Short ground contact (150 ms at 2000 N)
  for i = 100; i < 250; i = i + 1 {
    let t = i.to_double() / 1000.0
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, 2000.0),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
  }
  // Flight phase (400 ms at 0 N)
  for i = 250; i < 650; i = i + 1 {
    let t = i.to_double() / 1000.0
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::zero(),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
  }
  // Landing
  for i = 650; i < 750; i = i + 1 {
    let t = i.to_double() / 1000.0
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, 1500.0),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
  }

  let trial = @core.ForceTrial::new(meta, samples)
  let dj_report = @jump.analyze_drop_jump_trial(trial, 70.0)

  assert_true(dj_report.rsi_flight_contact > 1.0)
  assert_true(dj_report.active_peak_force_n >= 2000.0)
}
