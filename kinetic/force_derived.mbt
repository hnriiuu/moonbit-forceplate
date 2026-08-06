///|
/// Standard acceleration due to gravity (m/s^2).
pub fn gravity_constant() -> Double {
  9.80665
}

///|
/// Estimates subject body mass (kg) from baseline quiet standing Fz samples (N).
pub fn estimate_body_mass(
  fz_samples : Array[Double],
  quiet_start_idx : Int,
  quiet_end_idx : Int,
) -> Double {
  let start = if quiet_start_idx < 0 { 0 } else { quiet_start_idx }
  let end = if quiet_end_idx > fz_samples.length() {
    fz_samples.length()
  } else {
    quiet_end_idx
  }
  let mut sum = 0.0
  let mut cnt = 0
  for i = start; i < end; i = i + 1 {
    sum = sum + fz_samples[i]
    cnt = cnt + 1
  }
  if cnt == 0 {
    70.0 // Default 70 kg fallback
  } else {
    let mean_weight_n = sum / cnt.to_double()
    mean_weight_n / gravity_constant()
  }
}

///|
/// Struct holding complete derived 1D kinematic and kinetic waveforms over time.
pub struct KinematicsWaveform {
  timestamps : Array[Double]
  fz : Array[Double]
  net_force : Array[Double]
  acceleration : Array[Double]
  velocity : Array[Double]
  displacement : Array[Double]
  power : Array[Double]
} derive(Debug, Eq)

///|
/// Computes acceleration, velocity, displacement, and mechanical power from vGRF (Fz) and body mass.
pub fn compute_kinematics_from_trial(
  trial : @core.ForceTrial,
  body_mass_kg : Double,
) -> KinematicsWaveform {
  let ts = trial.get_timestamps()
  let fz = trial.get_fz()
  let n = trial.length()

  let g = gravity_constant()
  let body_weight_n = body_mass_kg * g

  let net_f : Array[Double] = Array::new(capacity=n)
  let accel : Array[Double] = Array::new(capacity=n)

  for i = 0; i < n; i = i + 1 {
    let nf = fz[i] - body_weight_n
    net_f.push(nf)
    accel.push(nf / body_mass_kg)
  }

  let vel = cumulative_integrate(ts, accel)
  let disp = cumulative_integrate(ts, vel)

  let pwr : Array[Double] = Array::new(capacity=n)
  for i = 0; i < n; i = i + 1 {
    pwr.push(fz[i] * vel[i])
  }

  {
    timestamps: ts,
    fz,
    net_force: net_f,
    acceleration: accel,
    velocity: vel,
    displacement: disp,
    power: pwr,
  }
}
