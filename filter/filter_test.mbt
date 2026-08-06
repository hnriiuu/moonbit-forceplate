///|
test "Butterworth lowpass coefficients generation" {
  let coeffs = @filter.compute_butterworth_lowpass(10.0, 1000.0)
  assert_true(coeffs.b0 > 0.0)
  assert_true(coeffs.b1 > 0.0)
  assert_true(coeffs.b2 > 0.0)
}

///|
test "Biquad forward filtering reduces high frequency noise" {
  let coeffs = @filter.compute_butterworth_lowpass(10.0, 1000.0)
  let noisy : Array[Double] = []
  for i = 0; i < 200; i = i + 1 {
    let noise = if i % 2 == 0 { 50.0 } else { -50.0 }
    noisy.push(700.0 + noise)
  }
  let filtered = @filter.apply_biquad_forward(noisy, coeffs)
  assert_eq(filtered.length(), 200)
  let diff_late = (filtered[100] - filtered[101]).abs()
  assert_true(diff_late < 20.0)
}

///|
test "Zero phase filtfilt retains sequence length" {
  let coeffs = @filter.compute_butterworth_lowpass(20.0, 1000.0)
  let sig : Array[Double] = [100.0, 200.0, 300.0, 400.0, 500.0, 600.0]
  let zero_p = @filter.apply_biquad_zero_phase(sig, coeffs)
  assert_eq(zero_p.length(), 6)
}

///|
test "Savitzky-Golay 5 and 7 smoothing tests" {
  let sig : Array[Double] = [10.0, 12.0, 15.0, 25.0, 14.0, 11.0, 10.0, 9.0]
  let sg5 = @filter.apply_savitzky_golay_5(sig)
  let sg7 = @filter.apply_savitzky_golay_7(sig)
  assert_eq(sg5.length(), 8)
  assert_eq(sg7.length(), 8)
}

///|
test "Moving average and threshold zeroing" {
  let sig : Array[Double] = [2.0, 100.0, 3.0, 150.0, 1.0]
  let ma = @filter.apply_moving_average(sig, 3)
  assert_eq(ma.length(), 5)

  let zeroed = @filter.apply_threshold_zeroing(sig, 5.0)
  assert_eq(zeroed[0], 0.0)
  assert_eq(zeroed[1], 100.0)
  assert_eq(zeroed[2], 0.0)
  assert_eq(zeroed[4], 0.0)
}

///|
test "Median filter removes isolated spike artifact" {
  let sig : Array[Double] = [10.0, 10.0, 10.0, 1000.0, 10.0, 10.0, 10.0]
  let med = @filter.apply_median_filter(sig, 5)
  assert_eq(med[3], 10.0)
}

///|
test "Notch filter and EMA filtering" {
  let coeffs = @filter.compute_notch_filter(50.0, 30.0, 1000.0)
  assert_true(coeffs.b0 > 0.0)

  let sig : Array[Double] = [10.0, 20.0, 30.0, 40.0, 50.0]
  let ema = @filter.apply_exponential_moving_average(sig, 0.2)
  assert_eq(ema.length(), 5)
  assert_true(ema[1] < 20.0)
}

///|
test "FIR lowpass Hamming window generation" {
  let fir = @filter.compute_fir_lowpass_hamming(20.0, 1000.0, 11)
  assert_eq(fir.length(), 11)
}
