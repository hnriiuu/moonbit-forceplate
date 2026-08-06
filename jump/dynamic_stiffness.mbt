///|
/// Result metrics for dynamic vertical and leg stiffness during jump landing / contact.
pub struct StiffnessReport {
  vertical_stiffness_n_m : Double
  leg_stiffness_n_m : Double
  center_of_mass_displacement_m : Double
  peak_impact_force_n : Double
  loading_rate_n_s : Double
} derive(Debug, Eq)

///|
/// Computes vertical stiffness (K_vert = F_max / delta_z) and leg stiffness during contact phase.
pub fn calculate_jump_stiffness(
  fz : Array[Double],
  disp : Array[Double],
  _body_mass_kg : Double,
  leg_length_m : Double,
) -> StiffnessReport {
  let n = fz.length()
  if n == 0 {
    return {
      vertical_stiffness_n_m: 0.0,
      leg_stiffness_n_m: 0.0,
      center_of_mass_displacement_m: 0.0,
      peak_impact_force_n: 0.0,
      loading_rate_n_s: 0.0,
    }
  }

  let peak_f = @core.compute_max(fz)
  let max_disp = @core.compute_max(disp).abs()

  let k_vert = if max_disp > 0.001 { peak_f / max_disp } else { 0.0 }

  let k_leg = if max_disp > 0.001 && leg_length_m > 0.1 {
    peak_f / (max_disp + leg_length_m * 0.05)
  } else {
    k_vert
  }

  let mut peak_i = 0
  for i = 0; i < n; i = i + 1 {
    if fz[i] == peak_f {
      peak_i = i
      break
    }
  }
  let loading_rate = if peak_i > 0 {
    peak_f / (peak_i.to_double() * 0.001)
  } else {
    0.0
  }

  {
    vertical_stiffness_n_m: k_vert,
    leg_stiffness_n_m: k_leg,
    center_of_mass_displacement_m: max_disp,
    peak_impact_force_n: peak_f,
    loading_rate_n_s: loading_rate,
  }
}
