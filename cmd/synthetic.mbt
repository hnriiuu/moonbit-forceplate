///|
fn tan_approx(x : Double) -> Double {
  let x2 = x * x
  let sin_x = x * (1.0 - x2 / 6.0 * (1.0 - x2 / 20.0))
  let cos_x = 1.0 - x2 / 2.0 * (1.0 - x2 / 12.0)
  if cos_x.abs() < 0.000000001 {
    0.0
  } else {
    sin_x / cos_x
  }
}

///|
/// Generates a realistic synthetic Countermovement Jump (CMJ) force plate trial recording.
pub fn generate_synthetic_cmj_trial(
  subject_id : String,
  body_mass_kg : Double,
  sampling_rate : Double,
) -> @core.ForceTrial {
  let meta = @core.TrialMetadata::new(
    subject_id, sampling_rate, body_mass_kg, "both",
  )
  let bw_n = body_mass_kg * @kinetic.gravity_constant()
  let dt = 1.0 / sampling_rate
  let samples : Array[@core.ForceSample] = []

  let mut current_t = 0.0

  // 1. Quiet standing (0.5 s)
  let n_quiet = (0.5 * sampling_rate).to_int()
  for i = 0; i < n_quiet; i = i + 1 {
    let noise = if i % 2 == 0 { 2.0 } else { -2.0 }
    samples.push(
      @core.ForceSample::new(
        current_t,
        @core.Vec3::new(0.0, 0.0, bw_n + noise),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
    current_t = current_t + dt
  }

  // 2. Unloading phase (0.2 s down to 0.45 * BW)
  let n_unloading = (0.2 * sampling_rate).to_int()
  for i = 0; i < n_unloading; i = i + 1 {
    let ratio = i.to_double() / n_unloading.to_double()
    let fz = bw_n - bw_n * 0.55 * ratio
    samples.push(
      @core.ForceSample::new(
        current_t,
        @core.Vec3::new(0.0, 0.0, fz),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
    current_t = current_t + dt
  }

  // 3. Propulsive phase (0.25 s up to 2.3 * BW)
  let n_prop = (0.25 * sampling_rate).to_int()
  for i = 0; i < n_prop; i = i + 1 {
    let ratio = i.to_double() / n_prop.to_double()
    let fz = bw_n * 0.45 + bw_n * 1.85 * ratio
    samples.push(
      @core.ForceSample::new(
        current_t,
        @core.Vec3::new(0.0, 0.0, fz),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
    current_t = current_t + dt
  }

  // 4. Flight phase (0.45 s at 0 N)
  let n_flight = (0.45 * sampling_rate).to_int()
  for i = 0; i < n_flight; i = i + 1 {
    samples.push(
      @core.ForceSample::new(
        current_t,
        @core.Vec3::zero(),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
    current_t = current_t + dt
  }

  // 5. Landing impact phase (0.3 s peak 2.6 * BW)
  let n_land = (0.3 * sampling_rate).to_int()
  for i = 0; i < n_land; i = i + 1 {
    let ratio = i.to_double() / n_land.to_double()
    let fz = if ratio < 0.3 {
      bw_n * 2.6 * (ratio / 0.3)
    } else {
      bw_n * 2.6 * (1.0 - (ratio - 0.3) / 0.7) + bw_n * (ratio - 0.3) / 0.7
    }
    samples.push(
      @core.ForceSample::new(
        current_t,
        @core.Vec3::new(0.0, 0.0, fz),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
    current_t = current_t + dt
  }

  @core.ForceTrial::new(meta, samples)
}

///|
/// Generates synthetic static balance COP sway trial.
pub fn generate_synthetic_sway_trial(
  subject_id : String,
  duration_s : Double,
  sampling_rate : Double,
) -> @core.ForceTrial {
  let meta = @core.TrialMetadata::new(subject_id, sampling_rate, 70.0, "both")
  let dt = 1.0 / sampling_rate
  let n = (duration_s * sampling_rate).to_int()
  let samples : Array[@core.ForceSample] = Array::new(capacity=n)
  let pi = 3.14159265358979323846

  let mut t = 0.0
  for i = 0; i < n; i = i + 1 {
    let cop_x = 5.0 * tan_approx(i.to_double() * 2.0 * pi * 0.3 / sampling_rate)
    let cop_y = 8.0 * tan_approx(i.to_double() * 2.0 * pi * 0.5 / sampling_rate)
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, 686.4),
        @core.Vec3::zero(),
        @core.CoPPoint::new(cop_x, cop_y),
      ),
    )
    t = t + dt
  }
  @core.ForceTrial::new(meta, samples)
}
