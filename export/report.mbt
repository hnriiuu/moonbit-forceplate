///|
/// Generates an ASCII sparkline representation of a 1D signal (using characters  ▂▃▄▅▆▇█).
pub fn generate_ascii_sparkline(signal : Array[Double], width : Int) -> String {
  let n = signal.length()
  if n == 0 || width <= 0 {
    return ""
  }
  let norm = @resample.time_normalize_signal(signal, width)
  let min_v = @core.compute_min(norm)
  let max_v = @core.compute_max(norm)
  let range = max_v - min_v

  let chars = [" ", " ", "▂", "▃", "▄", "▅", "▆", "▇", "█"]
  let sb = StringBuilder::new()

  for i = 0; i < width; i = i + 1 {
    let level = if range.abs() < 0.000001 {
      0
    } else {
      let norm_val = (norm[i] - min_v) / range
      (norm_val * 8.0).to_int()
    }
    let idx = if level < 0 { 0 } else if level > 8 { 8 } else { level }
    sb.write_string(chars[idx])
  }
  sb.to_string()
}

///|
/// Formats a complete, publication-ready ASCII Biomechanics Summary Report for CMJ test.
pub fn format_cmj_ascii_report(
  trial : @core.ForceTrial,
  cmj : @jump.CMJReport,
) -> String {
  let sb = StringBuilder::new()
  let fz = trial.get_fz()
  let spark = generate_ascii_sparkline(fz, 40)

  sb.write_string(
    "======================================================================\n",
  )
  sb.write_string(
    "            MOONBIT FORCE PLATE BIOMECHANICS REPORT (CMJ)             \n",
  )
  sb.write_string(
    "======================================================================\n",
  )
  sb.write_string("Subject ID      : ")
  sb.write_string(trial.metadata.subject_id)
  sb.write_string("\nSampling Rate   : ")
  sb.write_string(trial.metadata.sampling_rate.to_string())
  sb.write_string(" Hz\n")
  sb.write_string("Body Mass       : ")
  sb.write_string(trial.metadata.nominal_body_mass.to_string())
  sb.write_string(" kg\n")
  sb.write_string(
    "----------------------------------------------------------------------\n",
  )
  sb.write_string("FORCE-TIME CURVE: [")
  sb.write_string(spark)
  sb.write_string("]\n")
  sb.write_string(
    "----------------------------------------------------------------------\n",
  )
  sb.write_string("JUMP PERFORMANCE METRICS:\n")
  sb.write_string("  Jump Height (Flight Time)  : ")
  sb.write_string((cmj.jump_height_flight_m * 100.0).to_string())
  sb.write_string(" cm\n")
  sb.write_string("  Jump Height (Impulse)      : ")
  sb.write_string((cmj.jump_height_impulse_m * 100.0).to_string())
  sb.write_string(" cm\n")
  sb.write_string("  RSI-Modified (m/s)         : ")
  sb.write_string(cmj.rsi_modified.to_string())
  sb.write_string("\n")
  sb.write_string("  Takeoff Velocity (m/s)     : ")
  sb.write_string(cmj.takeoff_velocity_m_s.to_string())
  sb.write_string("\n")
  sb.write_string("  Peak Force (N)             : ")
  sb.write_string(cmj.peak_force_n.to_string())
  sb.write_string(" (")
  sb.write_string(cmj.peak_force_rel_bw.to_string())
  sb.write_string(" BW)\n")
  sb.write_string("  Peak Power (W)             : ")
  sb.write_string(cmj.peak_power_w.to_string())
  sb.write_string(" (")
  sb.write_string(cmj.peak_power_rel_w_kg.to_string())
  sb.write_string(" W/kg)\n")
  sb.write_string(
    "----------------------------------------------------------------------\n",
  )
  sb.write_string("PHASE TIMINGS (s):\n")
  sb.write_string("  Eccentric/Braking Phase    : ")
  sb.write_string(cmj.eccentric_duration_s.to_string())
  sb.write_string(" s\n")
  sb.write_string("  Concentric/Propulsive Phase: ")
  sb.write_string(cmj.concentric_duration_s.to_string())
  sb.write_string(" s\n")
  sb.write_string("  Time to Takeoff            : ")
  sb.write_string(cmj.time_to_takeoff_s.to_string())
  sb.write_string(" s\n")
  sb.write_string(
    "======================================================================\n",
  )
  sb.to_string()
}
