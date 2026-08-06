///|
/// Phase duration breakdown (in seconds) for jump analysis.
pub struct PhaseDurations {
  unloading_duration : Double
  braking_duration : Double
  propulsive_duration : Double
  flight_duration : Double
  contact_duration : Double
  total_movement_duration : Double
} derive(Debug, Eq)

///|
/// Phase sample index boundaries.
pub struct PhaseIntervals {
  quiet_phase : (Int, Int)
  unloading_phase : (Int, Int)
  braking_phase : (Int, Int)
  propulsive_phase : (Int, Int)
  flight_phase : (Int, Int)
  landing_phase : (Int, Int)
} derive(Debug, Eq)

///|
/// Segments a jump trial into distinct biomechanical phases using kinematics (velocity zero-crossing).
pub fn segment_jump_phases(
  ts : Array[Double],
  fz : Array[Double],
  events : EventIndices,
  body_mass_kg : Double,
) -> PhaseIntervals {
  let g = @kinetic.gravity_constant()
  let body_weight = body_mass_kg * g
  let n = fz.length()

  // Compute velocity to identify lowest velocity / transition point
  let net_f : Array[Double] = Array::new(capacity=n)
  for i = 0; i < n; i = i + 1 {
    net_f.push((fz[i] - body_weight) / body_mass_kg)
  }
  let vel = @kinetic.cumulative_integrate(ts, net_f)

  // Find minimum velocity index between onset and takeoff (end of braking phase)
  let mut min_vel_i = events.onset_idx
  let mut min_v = if events.onset_idx < n { vel[events.onset_idx] } else { 0.0 }
  for i = events.onset_idx; i < events.takeoff_idx; i = i + 1 {
    if vel[i] < min_v {
      min_v = vel[i]
      min_vel_i = i
    }
  }

  {
    quiet_phase: (0, events.onset_idx),
    unloading_phase: (events.onset_idx, events.min_force_idx),
    braking_phase: (events.min_force_idx, min_vel_i),
    propulsive_phase: (min_vel_i, events.takeoff_idx),
    flight_phase: (events.takeoff_idx, events.landing_idx),
    landing_phase: (
      events.landing_idx,
      if events.landing_idx + 200 < n {
        events.landing_idx + 200
      } else {
        n
      },
    ),
  }
}

///|
/// Computes duration metrics (seconds) from PhaseIntervals and timestamps array.
pub fn compute_phase_durations(
  ts : Array[Double],
  phases : PhaseIntervals,
) -> PhaseDurations {
  fn get_dur(p : (Int, Int)) -> Double {
    let (s, e) = p
    if s < ts.length() && e < ts.length() && e >= s {
      ts[e] - ts[s]
    } else {
      0.0
    }
  }

  let unl = get_dur(phases.unloading_phase)
  let brk = get_dur(phases.braking_phase)
  let prp = get_dur(phases.propulsive_phase)
  let flt = get_dur(phases.flight_phase)
  let cnt = unl + brk + prp

  {
    unloading_duration: unl,
    braking_duration: brk,
    propulsive_duration: prp,
    flight_duration: flt,
    contact_duration: cnt,
    total_movement_duration: cnt + flt,
  }
}
