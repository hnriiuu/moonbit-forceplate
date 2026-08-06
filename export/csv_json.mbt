///|
/// Formats a ForceTrial into standard CSV lines: timestamp, Fx, Fy, Fz, Mx, My, Mz, CoPx, CoPy.
pub fn export_trial_to_csv(trial : @core.ForceTrial) -> String {
  let sb = StringBuilder::new()
  sb.write_string("timestamp,fx,fy,fz,mx,my,mz,cop_x,cop_y\n")
  for i = 0; i < trial.samples.length(); i = i + 1 {
    let s = trial.samples[i]
    sb.write_string(s.timestamp.to_string())
    sb.write_string(",")
    sb.write_string(s.force.x.to_string())
    sb.write_string(",")
    sb.write_string(s.force.y.to_string())
    sb.write_string(",")
    sb.write_string(s.force.z.to_string())
    sb.write_string(",")
    sb.write_string(s.moment.x.to_string())
    sb.write_string(",")
    sb.write_string(s.moment.y.to_string())
    sb.write_string(",")
    sb.write_string(s.moment.z.to_string())
    sb.write_string(",")
    sb.write_string(s.cop.x.to_string())
    sb.write_string(",")
    sb.write_string(s.cop.y.to_string())
    sb.write_string("\n")
  }
  sb.to_string()
}

///|
/// Exports CMJ report metrics into JSON format string.
pub fn export_cmj_json(cmj : @jump.CMJReport) -> String {
  let sb = StringBuilder::new()
  sb.write_string("{\n")
  sb.write_string("  \"jump_height_flight_m\": ")
  sb.write_string(cmj.jump_height_flight_m.to_string())
  sb.write_string(",\n  \"jump_height_impulse_m\": ")
  sb.write_string(cmj.jump_height_impulse_m.to_string())
  sb.write_string(",\n  \"rsi_modified\": ")
  sb.write_string(cmj.rsi_modified.to_string())
  sb.write_string(",\n  \"peak_force_n\": ")
  sb.write_string(cmj.peak_force_n.to_string())
  sb.write_string(",\n  \"peak_power_w\": ")
  sb.write_string(cmj.peak_power_w.to_string())
  sb.write_string(",\n  \"takeoff_velocity_m_s\": ")
  sb.write_string(cmj.takeoff_velocity_m_s.to_string())
  sb.write_string("\n}")
  sb.to_string()
}
