///|
/// Result metrics for Isometric Mid-Thigh Pull (IMTP) force plate protocol.
pub struct IMTPReport {
  peak_force_n : Double
  peak_force_rel_bw : Double
  force_at_50ms_n : Double
  force_at_100ms_n : Double
  force_at_150ms_n : Double
  force_at_200ms_n : Double
  rfd_0_50ms_n_s : Double
  rfd_0_100ms_n_s : Double
  rfd_0_150ms_n_s : Double
  rfd_0_200ms_n_s : Double
  peak_rfd_n_s : Double
  time_to_peak_force_s : Double
} derive(Debug, Eq)

///|
/// Analyzes an Isometric Mid-Thigh Pull (IMTP) force plate trial.
pub fn analyze_imtp_trial(
  trial : @core.ForceTrial,
  body_mass_kg : Double,
) -> IMTPReport {
  let ts = trial.get_timestamps()
  let fz = trial.get_fz()
  let n = trial.length()
  let g = @kinetic.gravity_constant()
  let body_weight = body_mass_kg * g

  let quiet_cnt = if n > 100 { 100 } else { n / 2 }
  let quiet_fz : Array[Double] = Array::new(capacity=quiet_cnt)
  for i = 0; i < quiet_cnt; i = i + 1 {
    quiet_fz.push(fz[i])
  }
  let base_mean = @core.compute_mean(quiet_fz)
  let base_sd = @core.compute_std_dev(quiet_fz)

  let onset_i = @event.detect_movement_onset_5sd(fz, base_mean, base_sd)
  let onset_t = if onset_i < n { ts[onset_i] } else { 0.0 }

  let peak_f = @core.compute_max(fz)
  let peak_i = @event.find_peak_force_index(fz, onset_i, n)
  let t_to_peak = if peak_i < n { ts[peak_i] - onset_t } else { 0.0 }

  let rfd_m = @kinetic.calculate_rfd_metrics(ts, fz, onset_i)

  fn force_at_dt(target_dt : Double) -> Double {
    let target_t = onset_t + target_dt
    let mut i = onset_i
    while i < n && ts[i] < target_t {
      i = i + 1
    }
    if i >= n {
      i = n - 1
    }
    fz[i]
  }

  {
    peak_force_n: peak_f,
    peak_force_rel_bw: peak_f / body_weight,
    force_at_50ms_n: force_at_dt(0.05),
    force_at_100ms_n: force_at_dt(0.10),
    force_at_150ms_n: force_at_dt(0.15),
    force_at_200ms_n: force_at_dt(0.20),
    rfd_0_50ms_n_s: rfd_m.rfd_0_50ms,
    rfd_0_100ms_n_s: rfd_m.rfd_0_100ms,
    rfd_0_150ms_n_s: rfd_m.rfd_0_150ms,
    rfd_0_200ms_n_s: rfd_m.rfd_0_200ms,
    peak_rfd_n_s: rfd_m.peak_rfd,
    time_to_peak_force_s: t_to_peak,
  }
}

///|
/// Computes Dynamic Strength Deficit (DSD) = CMJ Peak Force / IMTP Peak Force.
pub fn calculate_dynamic_strength_deficit(
  cmj_peak_force_n : Double,
  imtp_peak_force_n : Double,
) -> Double {
  if imtp_peak_force_n.abs() < 0.000001 {
    0.0
  } else {
    cmj_peak_force_n / imtp_peak_force_n
  }
}

///|
/// Result metrics for Pogo / Repeated Hopping test protocol.
pub struct PogoTestReport {
  num_hops : Int
  mean_contact_time_s : Double
  mean_flight_time_s : Double
  mean_rsi : Double
  contact_time_cv_percent : Double
  rsi_max : Double
} derive(Debug, Eq)

///|
/// Analyzes a Pogo Jump / Repeated Hopping force plate trial.
pub fn analyze_pogo_trial(
  trial : @core.ForceTrial,
  _body_mass_kg : Double,
) -> PogoTestReport {
  let ts = trial.get_timestamps()
  let fz = trial.get_fz()
  let n = trial.length()

  let contacts : Array[Double] = []
  let flights : Array[Double] = []
  let rsis : Array[Double] = []

  let mut in_contact = fz[0] >= 20.0
  let mut state_start_t = ts[0]

  for i = 1; i < n; i = i + 1 {
    let curr_contact = fz[i] >= 20.0
    if curr_contact != in_contact {
      let dur = ts[i] - state_start_t
      if in_contact {
        if dur >= 0.04 {
          contacts.push(dur)
        }
      } else if dur >= 0.04 {
        flights.push(dur)
      }
      in_contact = curr_contact
      state_start_t = ts[i]
    }
  }

  let num_hops = if contacts.length() < flights.length() {
    contacts.length()
  } else {
    flights.length()
  }

  for k = 0; k < num_hops; k = k + 1 {
    let c = contacts[k]
    let f = flights[k]
    let rsi = if c > 0.001 { f / c } else { 0.0 }
    rsis.push(rsi)
  }

  let mean_c = @core.compute_mean(contacts)
  let sd_c = @core.compute_std_dev(contacts)
  let cv_c = if mean_c > 0.001 { sd_c / mean_c * 100.0 } else { 0.0 }

  let mean_f = @core.compute_mean(flights)
  let mean_rsi = if mean_c > 0.001 { mean_f / mean_c } else { 0.0 }
  let max_rsi = @core.compute_max(rsis)

  {
    num_hops,
    mean_contact_time_s: mean_c,
    mean_flight_time_s: mean_f,
    mean_rsi,
    contact_time_cv_percent: cv_c,
    rsi_max: max_rsi,
  }
}
