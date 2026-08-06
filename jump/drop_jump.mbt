///|
/// Result metrics for a Drop Jump / Depth Jump (DJ) force plate analysis.
pub struct DropJumpReport {
  contact_time_s : Double
  flight_time_s : Double
  jump_height_m : Double
  rsi_flight_contact : Double
  rsi_height_contact : Double
  initial_impact_peak_n : Double
  active_peak_force_n : Double
  loading_rate_n_s : Double
  dynamic_stiffness_n_m : Double
  events : @event.EventIndices
} derive(Debug, Eq)

///|
/// Analyzes a Drop Jump trial (stepping off a box onto the force plate and jumping vertically).
pub fn analyze_drop_jump_trial(
  trial : @core.ForceTrial,
  body_mass_kg : Double,
) -> DropJumpReport {
  let g = @kinetic.gravity_constant()
  let ts = trial.get_timestamps()
  let fz = trial.get_fz()

  let events = @event.detect_all_jump_events(trial, body_mass_kg)
  let phases = @event.segment_jump_phases(ts, fz, events, body_mass_kg)
  let phase_durs = @event.compute_phase_durations(ts, phases)
  let wf = @kinetic.compute_kinematics_from_trial(trial, body_mass_kg)

  // Ground contact time during drop jump landing-takeoff phase
  let t_contact = phase_durs.contact_duration
  let t_flight = phase_durs.flight_duration
  let h_flight = g * t_flight * t_flight / 8.0

  let rsi_fc = if t_contact > 0.001 { t_flight / t_contact } else { 0.0 }
  let rsi_hc = if t_contact > 0.001 { h_flight / t_contact } else { 0.0 }

  let peak_f = @core.compute_max(fz)
  // Find initial impact peak (within first 50ms of contact)
  let initial_window_end = events.onset_idx + 50
  let impact_f = @core.compute_max(
    sub_array(fz, events.onset_idx, initial_window_end),
  )

  let dt_impact = if initial_window_end < ts.length() {
    ts[initial_window_end] - ts[events.onset_idx]
  } else {
    0.05
  }
  let loading_rate = if dt_impact > 0.0001 { impact_f / dt_impact } else { 0.0 }

  // Dynamic leg stiffness: K_leg = F_peak / max_displacement
  let max_disp = @core.compute_max(wf.displacement)
  let stiffness = if max_disp.abs() > 0.0001 {
    peak_f / max_disp.abs()
  } else {
    0.0
  }

  {
    contact_time_s: t_contact,
    flight_time_s: t_flight,
    jump_height_m: h_flight,
    rsi_flight_contact: rsi_fc,
    rsi_height_contact: rsi_hc,
    initial_impact_peak_n: impact_f,
    active_peak_force_n: peak_f,
    loading_rate_n_s: loading_rate,
    dynamic_stiffness_n_m: stiffness,
    events,
  }
}
