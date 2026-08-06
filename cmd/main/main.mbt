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

  // 1. Generate synthetic CMJ trial
  let cmj_trial = @cmd.generate_synthetic_cmj_trial(
    "Athlete_PRO_01", 75.0, 1000.0,
  )
  println(
    "[+] Synthetic CMJ trial generated: 75.0 kg, 1000 Hz, " +
    cmj_trial.length().to_string() +
    " frames",
  )

  // 2. Filter trial using 2nd order Butterworth lowpass filter (10 Hz cutoff)
  let filtered_trial = @filter.filter_trial_forces(cmj_trial, 10.0, true)
  println("[+] Zero-phase 4th order Butterworth filter applied (fc = 10 Hz)")

  // 3. Analyze CMJ biomechanics
  let cmj_report = @jump.analyze_cmj_trial(filtered_trial, 75.0)

  // 4. Print ASCII Report
  let ascii_rpt = @export.format_cmj_ascii_report(filtered_trial, cmj_report)
  println(ascii_rpt)

  // 5. Static sway analysis
  let sway_trial = @cmd.generate_synthetic_sway_trial(
    "Athlete_PRO_01", 10.0, 100.0,
  )
  let sway_report = @sway.analyze_sway_trial(sway_trial)
  println(
    "----------------------------------------------------------------------",
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
  println(
    "======================================================================",
  )
}
