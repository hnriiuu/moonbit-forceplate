///|
/// Result metrics for frequency-domain posturography power spectral analysis.
pub struct SpectralSwayReport {
  total_power : Double
  mean_frequency_hz : Double
  median_frequency_hz : Double
  peak_frequency_hz : Double
  low_freq_power_0_to_0p5hz : Double
  mid_freq_power_0p5_to_2hz : Double
  high_freq_power_2_to_10hz : Double
} derive(Debug, Eq)

///|
/// Computes Power Spectral Density (PSD) and spectral parameters for COP sway series.
pub fn analyze_cop_spectral_density(
  cop_series : Array[Double],
  sample_rate : Double,
) -> SpectralSwayReport {
  let n = cop_series.length()
  if n < 4 {
    return {
      total_power: 0.0,
      mean_frequency_hz: 0.0,
      median_frequency_hz: 0.0,
      peak_frequency_hz: 0.0,
      low_freq_power_0_to_0p5hz: 0.0,
      mid_freq_power_0p5_to_2hz: 0.0,
      high_freq_power_2_to_10hz: 0.0,
    }
  }

  let mean = @core.compute_mean(cop_series)
  let pi = 3.14159265358979323846
  let num_freqs = n / 2

  let freqs : Array[Double] = Array::new(capacity=num_freqs)
  let psd : Array[Double] = Array::new(capacity=num_freqs)

  let mut total_p = 0.0
  let mut max_p = 0.0
  let mut peak_f = 0.0

  for k = 0; k < num_freqs; k = k + 1 {
    let f = k.to_double() * sample_rate / n.to_double()
    freqs.push(f)

    let mut real_part = 0.0
    let mut imag_part = 0.0

    for i = 0; i < n; i = i + 1 {
      let angle = 2.0 * pi * k.to_double() * i.to_double() / n.to_double()
      let x = cop_series[i] - mean
      real_part = real_part + x * @filter.cos_approx(angle)
      imag_part = imag_part - x * @filter.sin_approx(angle)
    }

    let p = (real_part * real_part + imag_part * imag_part) / n.to_double()
    psd.push(p)
    total_p = total_p + p

    if p > max_p {
      max_p = p
      peak_f = f
    }
  }

  let mut weighted_f_sum = 0.0
  let mut low_p = 0.0
  let mut mid_p = 0.0
  let mut high_p = 0.0

  for k = 0; k < num_freqs; k = k + 1 {
    let f = freqs[k]
    let p = psd[k]
    weighted_f_sum = weighted_f_sum + f * p

    if f <= 0.5 {
      low_p = low_p + p
    } else if f <= 2.0 {
      mid_p = mid_p + p
    } else if f <= 10.0 {
      high_p = high_p + p
    }
  }

  let mean_f = if total_p > 0.000001 { weighted_f_sum / total_p } else { 0.0 }

  // Median frequency: frequency where cumulative power reaches 50%
  let half_p = total_p / 2.0
  let mut cum_p = 0.0
  let mut med_f = 0.0
  for k = 0; k < num_freqs; k = k + 1 {
    cum_p = cum_p + psd[k]
    if cum_p >= half_p {
      med_f = freqs[k]
      break
    }
  }

  {
    total_power: total_p,
    mean_frequency_hz: mean_f,
    median_frequency_hz: med_f,
    peak_frequency_hz: peak_f,
    low_freq_power_0_to_0p5hz: low_p,
    mid_freq_power_0p5_to_2hz: mid_p,
    high_freq_power_2_to_10hz: high_p,
  }
}
