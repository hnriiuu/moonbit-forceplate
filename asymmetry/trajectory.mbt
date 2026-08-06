///|
/// Dynamic time-normalized (101 points) bilateral asymmetry profile.
pub struct AsymmetryTrajectory {
  time_percent : Array[Double]
  left_fz_norm : Array[Double]
  right_fz_norm : Array[Double]
  asymmetry_index_curve : Array[Double]
} derive(Debug, Eq)

///|
/// Computes 101-point time-normalized bilateral force asymmetry curve.
pub fn compute_asymmetry_trajectory(
  left_trial : @core.ForceTrial,
  right_trial : @core.ForceTrial,
) -> AsymmetryTrajectory {
  let left_fz = left_trial.get_fz()
  let right_fz = right_trial.get_fz()

  let l_norm = @resample.time_normalize_signal(left_fz, 101)
  let r_norm = @resample.time_normalize_signal(right_fz, 101)

  let t_pct : Array[Double] = Array::new(capacity=101)
  let asym_curve : Array[Double] = Array::new(capacity=101)

  for i = 0; i < 101; i = i + 1 {
    t_pct.push(i.to_double())
    let si = calculate_symmetry_index(l_norm[i], r_norm[i])
    asym_curve.push(si)
  }

  {
    time_percent: t_pct,
    left_fz_norm: l_norm,
    right_fz_norm: r_norm,
    asymmetry_index_curve: asym_curve,
  }
}
