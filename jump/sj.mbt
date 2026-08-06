///|
/// Result metrics for a Squat Jump (SJ) force plate analysis.
pub struct SJReport {
  jump_height_flight_m : Double
  jump_height_impulse_m : Double
  peak_force_n : Double
  peak_power_w : Double
  concentric_duration_s : Double
  countermovement_dip_detected : Bool
  max_countermovement_dip_n : Double
  events : @event.EventIndices
} derive(Debug, Eq)

///|
/// Analyzes a Squat Jump trial, evaluating push-off metrics and flagging invalid countermovement dips.
pub fn analyze_sj_trial(
  trial : @core.ForceTrial,
  body_mass_kg : Double,
) -> SJReport {
  let g = @kinetic.gravity_constant()
  let body_weight = body_mass_kg * g
  let ts = trial.get_timestamps()
  let fz = trial.get_fz()

  let events = @event.detect_all_jump_events(trial, body_mass_kg)
  let phases = @event.segment_jump_phases(ts, fz, events, body_mass_kg)
  let phase_durs = @event.compute_phase_durations(ts, phases)
  let wf = @kinetic.compute_kinematics_from_trial(trial, body_mass_kg)

  let t_flight = phase_durs.flight_duration
  let h_flight = g * t_flight * t_flight / 8.0

  let v_takeoff = if events.takeoff_idx < wf.velocity.length() {
    wf.velocity[events.takeoff_idx]
  } else {
    0.0
  }
  let h_impulse = v_takeoff * v_takeoff / (2.0 * g)

  // Check for countermovement dip: force dropping below 95% BW prior to push-off
  let prior_slice = sub_array(fz, events.onset_idx, events.takeoff_idx)
  let min_f_prior = @core.compute_min(prior_slice)
  let dip_val = body_weight - min_f_prior
  let dip_detected = min_f_prior < body_weight * 0.95

  let peak_f = @core.compute_max(fz)
  let peak_p = @core.compute_max(wf.power)

  {
    jump_height_flight_m: h_flight,
    jump_height_impulse_m: h_impulse,
    peak_force_n: peak_f,
    peak_power_w: peak_p,
    concentric_duration_s: phase_durs.propulsive_duration,
    countermovement_dip_detected: dip_detected,
    max_countermovement_dip_n: if dip_val > 0.0 {
      dip_val
    } else {
      0.0
    },
    events,
  }
}
