///|
fn sin_approx(x : Double) -> Double {
  let x2 = x * x
  x * (1.0 - x2 / 6.0 * (1.0 - x2 / 20.0 * (1.0 - x2 / 42.0)))
}

///|
/// Generates synthetic Vertical Ground Reaction Force (vGRF) waveform for Countermovement Jump (CMJ).
pub fn generate_synthetic_cmj_trial(
  subject_id : String,
  sampling_rate : Double,
  body_mass_kg : Double,
) -> @core.ForceTrial {
  let meta = @core.TrialMetadata::new(
    subject_id, sampling_rate, body_mass_kg, "both",
  )
  let samples : Array[@core.ForceSample] = []
  let g = @kinetic.gravity_constant()
  let bw_n = body_mass_kg * g
  let dt = 1.0 / sampling_rate

  // 1. Quiet standing (500 ms)
  let n_quiet = (0.500 * sampling_rate).to_int()
  for i = 0; i < n_quiet; i = i + 1 {
    let t = i.to_double() * dt
    let noise = if i % 2 == 0 { 2.5 } else { -2.5 }
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, bw_n + noise),
        @core.Vec3::zero(),
        @core.CoPPoint::new(0.0, 0.0),
      ),
    )
  }

  // 2. Unloading & Dip Phase (200 ms)
  let n_dip = (0.200 * sampling_rate).to_int()
  let start_t1 = n_quiet.to_double() * dt
  let pi = 3.14159265358979323846
  for i = 0; i < n_dip; i = i + 1 {
    let t = start_t1 + i.to_double() * dt
    let ratio = i.to_double() / n_dip.to_double() * pi
    let fz = bw_n - bw_n * 0.45 * sin_approx(ratio)
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, fz),
        @core.Vec3::zero(),
        @core.CoPPoint::new(0.0, 0.0),
      ),
    )
  }

  // 3. Braking & Propulsive Drive Phase (250 ms)
  let n_prop = (0.250 * sampling_rate).to_int()
  let start_t2 = start_t1 + n_dip.to_double() * dt
  for i = 0; i < n_prop; i = i + 1 {
    let t = start_t2 + i.to_double() * dt
    let ratio = i.to_double() / n_prop.to_double() * pi
    let fz = bw_n + bw_n * 1.5 * sin_approx(ratio)
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, fz),
        @core.Vec3::zero(),
        @core.CoPPoint::new(0.0, 0.0),
      ),
    )
  }

  // 4. Flight Phase (400 ms)
  let n_flight = (0.400 * sampling_rate).to_int()
  let start_t3 = start_t2 + n_prop.to_double() * dt
  for i = 0; i < n_flight; i = i + 1 {
    let t = start_t3 + i.to_double() * dt
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::zero(),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
  }

  // 5. Landing Impact Phase (350 ms)
  let n_land = (0.350 * sampling_rate).to_int()
  let start_t4 = start_t3 + n_flight.to_double() * dt
  for i = 0; i < n_land; i = i + 1 {
    let t = start_t4 + i.to_double() * dt
    let decay = 1.0 - i.to_double() / n_land.to_double()
    let fz = bw_n + bw_n * 2.2 * decay
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, fz),
        @core.Vec3::zero(),
        @core.CoPPoint::new(0.0, 0.0),
      ),
    )
  }

  @core.ForceTrial::new(meta, samples)
}

///|
/// Generates synthetic quiet standing sway trial (COP trajectory).
pub fn generate_synthetic_sway_trial(
  subject_id : String,
  duration_s : Double,
  sampling_rate : Double,
) -> @core.ForceTrial {
  let meta = @core.TrialMetadata::new(subject_id, sampling_rate, 70.0, "both")
  let samples : Array[@core.ForceSample] = []
  let n = (duration_s * sampling_rate).to_int()
  let dt = 1.0 / sampling_rate
  let bw_n = 70.0 * 9.80665
  let pi = 3.14159265358979323846

  for i = 0; i < n; i = i + 1 {
    let t = i.to_double() * dt
    let cop_x = 5.0 * sin_approx(t * 0.5 * pi)
    let cop_y = 8.0 * sin_approx(t * 0.3 * pi)
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, bw_n),
        @core.Vec3::zero(),
        @core.CoPPoint::new(cop_x, cop_y),
      ),
    )
  }

  @core.ForceTrial::new(meta, samples)
}

///|
/// Generates synthetic Isometric Mid-Thigh Pull (IMTP) force trial.
pub fn generate_synthetic_imtp_trial(
  subject_id : String,
  sampling_rate : Double,
  body_mass_kg : Double,
) -> @core.ForceTrial {
  let meta = @core.TrialMetadata::new(
    subject_id, sampling_rate, body_mass_kg, "both",
  )
  let samples : Array[@core.ForceSample] = []
  let bw_n = body_mass_kg * 9.80665
  let dt = 1.0 / sampling_rate

  // 1. Quiet standing (300 ms)
  let n_quiet = (0.300 * sampling_rate).to_int()
  for i = 0; i < n_quiet; i = i + 1 {
    let t = i.to_double() * dt
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, bw_n),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
  }

  // 2. Maximal Isometric Pull (1500 ms)
  let n_pull = (1.500 * sampling_rate).to_int()
  let start_t = n_quiet.to_double() * dt
  let peak_n = bw_n * 4.2
  for i = 0; i < n_pull; i = i + 1 {
    let t = start_t + i.to_double() * dt
    let progress = i.to_double() / (0.300 * sampling_rate)
    let ramp = if progress > 1.0 { 1.0 } else { progress }
    let fz = bw_n + (peak_n - bw_n) * ramp
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, fz),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
  }

  @core.ForceTrial::new(meta, samples)
}
