///|
fn main {
  println(
    "======================================================================",
  )
  println(
    "           MOONBIT FORCE PLATE ANALYSIS SUITE (CLI DEMO)              ",
  )
  println(
    "======================================================================",
  )

  // 1. CMJ Analysis Demo
  let trial_cmj = @cmd.generate_synthetic_cmj_trial(
    "Athlete_PRO_01", 1000.0, 75.0,
  )
  println("[+] Synthetic CMJ trial generated: 75.0 kg, 1000 Hz")

  let fz_raw = trial_cmj.get_fz()
  let butter_coeffs = @filter.compute_butterworth_lowpass(10.0, 1000.0)
  let _fz_filtered = @filter.apply_biquad_zero_phase(fz_raw, butter_coeffs)
  println("[+] Zero-phase 4th order Butterworth filter applied (fc = 10 Hz)")

  let cmj_report = @jump.analyze_cmj_trial(trial_cmj, 75.0)
  let ascii_rpt = @export.format_cmj_ascii_report(trial_cmj, cmj_report)
  println(ascii_rpt)

  // 2. IMTP Analysis Demo
  println(
    "----------------------------------------------------------------------",
  )
  let trial_imtp = @cmd.generate_synthetic_imtp_trial(
    "Athlete_PRO_01", 1000.0, 75.0,
  )
  let imtp_report = @jump.analyze_imtp_trial(trial_imtp, 75.0)
  println("ISOMETRIC MID-THIGH PULL (IMTP) RESULTS:")
  println(
    "  IMTP Peak Force (N)      : " + imtp_report.peak_force_n.to_string(),
  )
  println(
    "  IMTP Relative Force (BW) : " + imtp_report.peak_force_rel_bw.to_string(),
  )
  println(
    "  Force at 100ms (N)       : " + imtp_report.force_at_100ms_n.to_string(),
  )
  println(
    "  Force at 200ms (N)       : " + imtp_report.force_at_200ms_n.to_string(),
  )
  println(
    "  Peak RFD (N/s)           : " + imtp_report.peak_rfd_n_s.to_string(),
  )

  let dsd = @jump.calculate_dynamic_strength_deficit(
    cmj_report.peak_force_n,
    imtp_report.peak_force_n,
  )
  println("  Dynamic Strength Deficit : " + dsd.to_string())

  // 3. Posturography Sway Demo
  println(
    "----------------------------------------------------------------------",
  )
  let trial_sway = @cmd.generate_synthetic_sway_trial(
    "Athlete_PRO_01", 10.0, 100.0,
  )
  let sway_report = @sway.analyze_sway_trial(trial_sway)
  let hull_area = @sway.compute_cop_convex_hull_area(
    trial_sway.get_cop_points(),
  )

  println("POSTUROGRAPHY STATIC BALANCE RESULTS (10s Trial):")
  println(
    "  Total COP Path Length  : " +
    sway_report.total_path_length_mm.to_string() +
    " mm",
  )
  println(
    "  Mean COP Velocity      : " +
    sway_report.mean_velocity_mm_s.to_string() +
    " mm/s",
  )
  println(
    "  95% Ellipse Area       : " +
    sway_report.ellipse_95_area_mm2.to_string() +
    " mm^2",
  )
  println("  Convex Hull Sway Area  : " + hull_area.to_string() + " mm^2")
  println(
    "======================================================================",
  )
}
