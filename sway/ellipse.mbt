///|
/// Computes 95% Confidence Ellipse Area from COP points array.
/// Uses eigenvalue decomposition of the 2D covariance matrix:
/// C = [[s_xx, s_xy], [s_xy, s_yy]]
/// Area = 5.991 * pi * sqrt(lambda1 * lambda2) where 5.991 is chi-squared value for p=0.05 (2 d.f.).
pub fn compute_cop_95_ellipse_area(
  cop_points : Array[@core.CoPPoint],
) -> Double {
  let n = cop_points.length()
  if n <= 2 {
    return 0.0
  }
  let ap = extract_ap_series(cop_points)
  let ml = extract_ml_series(cop_points)

  let mean_ap = @core.compute_mean(ap)
  let mean_ml = @core.compute_mean(ml)

  let mut s_xx = 0.0
  let mut s_yy = 0.0
  let mut s_xy = 0.0

  for i = 0; i < n; i = i + 1 {
    let dx = ml[i] - mean_ml
    let dy = ap[i] - mean_ap
    s_xx = s_xx + dx * dx
    s_yy = s_yy + dy * dy
    s_xy = s_xy + dx * dy
  }

  let div = (n - 1).to_double()
  s_xx = s_xx / div
  s_yy = s_yy / div
  s_xy = s_xy / div

  let trace = s_xx + s_yy
  let det = s_xx * s_yy - s_xy * s_xy
  let disc = (trace * trace / 4.0 - det).abs().sqrt()

  let lambda1 = trace / 2.0 + disc
  let lambda2 = trace / 2.0 - disc

  let l1 = if lambda1 < 0.0 { 0.0 } else { lambda1 }
  let l2 = if lambda2 < 0.0 { 0.0 } else { lambda2 }

  let pi = 3.14159265358979323846
  let chi_sq_95 = 5.99146
  chi_sq_95 * pi * (l1 * l2).sqrt()
}

///|
/// Performs complete posturography sway analysis on a ForceTrial.
pub fn analyze_sway_trial(trial : @core.ForceTrial) -> SwayReport {
  let cop_pts = trial.get_cop_points()
  let dur = trial.duration()

  let path_len = compute_cop_path_length(cop_pts)
  let velocity = if dur > 0.0001 { path_len / dur } else { 0.0 }

  let ap = extract_ap_series(cop_pts)
  let ml = extract_ml_series(cop_pts)

  let ap_max = @core.compute_max(ap)
  let ap_min = @core.compute_min(ap)
  let ap_m = @core.compute_mean(ap)
  let ap_sd = @core.compute_std_dev(ap)

  let ml_max = @core.compute_max(ml)
  let ml_min = @core.compute_min(ml)
  let ml_m = @core.compute_mean(ml)
  let ml_sd = @core.compute_std_dev(ml)

  let ellipse_area = compute_cop_95_ellipse_area(cop_pts)

  {
    total_path_length_mm: path_len,
    mean_velocity_mm_s: velocity,
    ap_range_mm: ap_max - ap_min,
    ap_mean_mm: ap_m,
    ap_std_dev_mm: ap_sd,
    ml_range_mm: ml_max - ml_min,
    ml_mean_mm: ml_m,
    ml_std_dev_mm: ml_sd,
    ellipse_95_area_mm2: ellipse_area,
  }
}
