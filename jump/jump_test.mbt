///|
test "CMJ complete analysis pipeline" {
  let meta = @core.TrialMetadata::new("Subj05", 1000.0, 70.0, "both")
  let samples : Array[@core.ForceSample] = []
  let bw_n = 70.0 * 9.80665

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

///|
test "IMTP analysis and Dynamic Strength Deficit" {
  let meta = @core.TrialMetadata::new("Subj14", 1000.0, 80.0, "both")
  let samples : Array[@core.ForceSample] = []
  let bw_n = 80.0 * 9.80665

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
  for i = 100; i < 500; i = i + 1 {
    let t = i.to_double() / 1000.0
    let fz = bw_n + (3500.0 - bw_n) * ((i - 100).to_double() / 400.0)
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, fz),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
  }

  let trial = @core.ForceTrial::new(meta, samples)
  let imtp = @jump.analyze_imtp_trial(trial, 80.0)

  assert_true(imtp.peak_force_n >= 3400.0)
  assert_true(imtp.force_at_200ms_n > bw_n)

  let dsd = @jump.calculate_dynamic_strength_deficit(1800.0, imtp.peak_force_n)
  assert_true(dsd > 0.4 && dsd < 0.6)
}

///|
test "Pogo repeated hopping test protocol" {
  let meta = @core.TrialMetadata::new("Subj15", 1000.0, 70.0, "both")
  let samples : Array[@core.ForceSample] = []

  for hop = 0; hop < 3; hop = hop + 1 {
    for i = 0; i < 150; i = i + 1 {
      let t = (hop * 550 + i).to_double() / 1000.0
      samples.push(
        @core.ForceSample::new(
          t,
          @core.Vec3::new(0.0, 0.0, 1500.0),
          @core.Vec3::zero(),
          @core.CoPPoint::zero(),
        ),
      )
    }
    for i = 150; i < 550; i = i + 1 {
      let t = (hop * 550 + i).to_double() / 1000.0
      samples.push(
        @core.ForceSample::new(
          t,
          @core.Vec3::zero(),
          @core.Vec3::zero(),
          @core.CoPPoint::zero(),
        ),
      )
    }
  }

  let trial = @core.ForceTrial::new(meta, samples)
  let pogo = @jump.analyze_pogo_trial(trial, 70.0)

  assert_true(pogo.num_hops >= 2)
  assert_true(pogo.mean_rsi > 1.5)
}
