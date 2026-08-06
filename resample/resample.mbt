///|
/// Resamples a 1D time series `(timestamps, values)` to a new target sampling frequency `target_fs_hz`.
pub fn resample_series_cubic(
  timestamps : Array[Double],
  values : Array[Double],
  target_fs_hz : Double,
) -> (Array[Double], Array[Double]) {
  let n = timestamps.length()
  if n < 2 {
    return (timestamps, values)
  }
  let t_start = timestamps[0]
  let t_end = timestamps[n - 1]
  let dt = 1.0 / target_fs_hz
  let num_new_samples = ((t_end - t_start) / dt).to_int() + 1

  let new_ts : Array[Double] = Array::new(capacity=num_new_samples)
  let new_vals : Array[Double] = Array::new(capacity=num_new_samples)

  let spline = fit_cubic_spline(timestamps, values)

  for i = 0; i < num_new_samples; i = i + 1 {
    let t = t_start + i.to_double() * dt
    if t <= t_end {
      new_ts.push(t)
      new_vals.push(spline.eval(t))
    }
  }

  (new_ts, new_vals)
}

///|
/// Time normalizes a signal array to `num_points` evenly spaced samples (default 101 points for 0-100% movement cycle).
pub fn time_normalize_signal(
  signal : Array[Double],
  num_points : Int,
) -> Array[Double] {
  let n = signal.length()
  if n == 0 {
    return []
  }
  if n == 1 || num_points <= 1 {
    let res : Array[Double] = Array::new(capacity=num_points)
    for i = 0; i < num_points; i = i + 1 {
      res.push(signal[0])
    }
    return res
  }

  let orig_ts : Array[Double] = Array::new(capacity=n)
  for i = 0; i < n; i = i + 1 {
    orig_ts.push(i.to_double() / (n - 1).to_double())
  }

  let spline = fit_cubic_spline(orig_ts, signal)
  let norm : Array[Double] = Array::new(capacity=num_points)

  for i = 0; i < num_points; i = i + 1 {
    let norm_t = i.to_double() / (num_points - 1).to_double()
    norm.push(spline.eval(norm_t))
  }
  norm
}

///|
/// Resamples a whole `ForceTrial` to a specified target sampling rate in Hz (e.g. 1000.0).
pub fn resample_trial(
  trial : @core.ForceTrial,
  target_fs_hz : Double,
) -> @core.ForceTrial {
  let n = trial.length()
  if n < 2 {
    return trial
  }
  let ts = trial.get_timestamps()
  let fx = trial.get_fx()
  let fy = trial.get_fy()
  let fz = trial.get_fz()

  let sp_fx = fit_cubic_spline(ts, fx)
  let sp_fy = fit_cubic_spline(ts, fy)
  let sp_fz = fit_cubic_spline(ts, fz)

  let t_start = ts[0]
  let t_end = ts[n - 1]
  let dt = 1.0 / target_fs_hz
  let num_new_samples = ((t_end - t_start) / dt).to_int() + 1

  let new_samples : Array[@core.ForceSample] = Array::new(
    capacity=num_new_samples,
  )

  for i = 0; i < num_new_samples; i = i + 1 {
    let t = t_start + i.to_double() * dt
    if t <= t_end {
      let x = sp_fx.eval(t)
      let y = sp_fy.eval(t)
      let z = sp_fz.eval(t)
      let f_vec = @core.Vec3::new(x, y, z)
      new_samples.push(
        @core.ForceSample::new(
          t,
          f_vec,
          @core.Vec3::zero(),
          @core.CoPPoint::zero(),
        ),
      )
    }
  }

  let new_meta = @core.TrialMetadata::new(
    trial.metadata.subject_id,
    target_fs_hz,
    trial.metadata.nominal_body_mass,
    trial.metadata.side,
  )
  @core.ForceTrial::new(new_meta, new_samples)
}
