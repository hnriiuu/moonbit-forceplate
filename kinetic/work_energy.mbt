///|
/// Structure holding complete mechanical work, kinetic energy, and potential energy metrics.
pub struct MechanicalEnergyMetrics {
  concentric_work_j : Double
  eccentric_work_j : Double
  net_work_j : Double
  peak_kinetic_energy_j : Double
  peak_potential_energy_j : Double
  rate_of_power_development_w_s : Double
} derive(Debug, Eq)

///|
/// Computes mechanical work and energy metrics from kinematics waveform.
pub fn calculate_mechanical_work(
  wf : KinematicsWaveform,
  body_mass_kg : Double,
) -> MechanicalEnergyMetrics {
  let ts = wf.timestamps
  let net_f = wf.net_force
  let vel = wf.velocity
  let pwr = wf.power
  let disp = wf.displacement
  let n = ts.length()
  let g = gravity_constant()

  let mut conc_work = 0.0
  let mut ecc_work = 0.0
  let mut net_work = 0.0

  for i = 0; i < n - 1; i = i + 1 {
    let dt = ts[i + 1] - ts[i]
    let avg_p = (pwr[i] + pwr[i + 1]) / 2.0
    let avg_nf = (net_f[i] + net_f[i + 1]) / 2.0
    let avg_v = (vel[i] + vel[i + 1]) / 2.0
    let inst_work = avg_nf * avg_v * dt

    net_work = net_work + inst_work
    if avg_p >= 0.0 {
      conc_work = conc_work + inst_work
    } else {
      ecc_work = ecc_work + inst_work.abs()
    }
  }

  let mut max_ke = 0.0
  let mut max_pe = 0.0
  for i = 0; i < n; i = i + 1 {
    let ke = 0.5 * body_mass_kg * vel[i] * vel[i]
    let pe = body_mass_kg * g * disp[i]
    if ke > max_ke {
      max_ke = ke
    }
    if pe > max_pe {
      max_pe = pe
    }
  }

  // Rate of Power Development (RPD = max dP/dt)
  let mut max_rpd = 0.0
  for i = 0; i < n - 1; i = i + 1 {
    let dt = ts[i + 1] - ts[i]
    if dt > 0.000001 {
      let rpd = (pwr[i + 1] - pwr[i]) / dt
      if rpd > max_rpd {
        max_rpd = rpd
      }
    }
  }

  {
    concentric_work_j: conc_work,
    eccentric_work_j: ecc_work,
    net_work_j: net_work,
    peak_kinetic_energy_j: max_ke,
    peak_potential_energy_j: max_pe,
    rate_of_power_development_w_s: max_rpd,
  }
}
