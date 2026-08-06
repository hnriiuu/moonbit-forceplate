///|
/// Formats a complete Markdown biomechanics report with LaTeX formulas and structured tables.
pub fn format_cmj_markdown_report(
  trial : @core.ForceTrial,
  cmj : @jump.CMJReport,
) -> String {
  let sb = StringBuilder::new()
  let fz = trial.get_fz()
  let spark = generate_ascii_sparkline(fz, 30)

  sb.write_string("# Countermovement Jump (CMJ) Biomechanics Report\n\n")
  sb.write_string("**Subject ID**: `" + trial.metadata.subject_id + "`\n")
  sb.write_string(
    "**Sampling Rate**: `" + trial.metadata.sampling_rate.to_string() + " Hz`\n",
  )
  sb.write_string(
    "**Body Mass**: `" +
    trial.metadata.nominal_body_mass.to_string() +
    " kg`\n\n",
  )

  sb.write_string("## Force-Time Curve Sparkline\n\n")
  sb.write_string("```text\n[" + spark + "]\n```\n\n")

  sb.write_string("## Primary Jump Performance Metrics\n\n")
  sb.write_string(
    "| Biomechanical Parameter | Measured Value | Unit | Method / Formula |\n",
  )
  sb.write_string("| :--- | :--- | :--- | :--- |\n")
  sb.write_string(
    "| Jump Height (Flight) | " +
    (cmj.jump_height_flight_m * 100.0).to_string() +
    " | cm | $h = \\frac{g t_{flight}^2}{8}$ |\n",
  )
  sb.write_string(
    "| Jump Height (Impulse) | " +
    (cmj.jump_height_impulse_m * 100.0).to_string() +
    " | cm | $h = \\frac{v_{takeoff}^2}{2g}$ |\n",
  )
  sb.write_string(
    "| Modified RSI (RSI-mod) | " +
    cmj.rsi_modified.to_string() +
    " | m/s | $\\text{RSI}_{mod} = \\frac{h}{t_{takeoff}}$ |\n",
  )
  sb.write_string(
    "| Takeoff Velocity | " +
    cmj.takeoff_velocity_m_s.to_string() +
    " | m/s | $v = \\frac{1}{m} \\int F_{net} dt$ |\n",
  )
  sb.write_string(
    "| Peak Force | " +
    cmj.peak_force_n.to_string() +
    " | N | Relative: " +
    cmj.peak_force_rel_bw.to_string() +
    " BW |\n",
  )
  sb.write_string(
    "| Peak Power | " +
    cmj.peak_power_w.to_string() +
    " | W | Relative: " +
    cmj.peak_power_rel_w_kg.to_string() +
    " W/kg |\n\n",
  )

  sb.write_string("## Phase Timing Breakdown\n\n")
  sb.write_string(
    "- **Eccentric / Braking Phase Duration**: `" +
    cmj.eccentric_duration_s.to_string() +
    " s`\n",
  )
  sb.write_string(
    "- **Concentric / Propulsive Phase Duration**: `" +
    cmj.concentric_duration_s.to_string() +
    " s`\n",
  )
  sb.write_string(
    "- **Total Time to Takeoff**: `" +
    cmj.time_to_takeoff_s.to_string() +
    " s`\n\n",
  )

  sb.to_string()
}
