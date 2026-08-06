///|
test "Lerp test" {
  let v = @resample.lerp(0.0, 10.0, 10.0, 30.0, 5.0)
  assert_eq(v, 20.0)
}

///|
test "Cubic Spline fitting and evaluation on quadratic function" {
  let xs : Array[Double] = [0.0, 1.0, 2.0, 3.0, 4.0]
  let ys : Array[Double] = [0.0, 1.0, 4.0, 9.0, 16.0]

  let spline = @resample.fit_cubic_spline(xs, ys)
  let y_mid = spline.eval(2.5)
  assert_true((y_mid - 6.25).abs() < 0.05)
}

///|
test "Time normalization produces 101 points" {
  let sig : Array[Double] = [10.0, 20.0, 40.0, 80.0, 100.0]
  let norm = @resample.time_normalize_signal(sig, 101)
  assert_eq(norm.length(), 101)
  assert_true((norm[0] - 10.0).abs() < 0.01)
  assert_true((norm[100] - 100.0).abs() < 0.01)
}

///|
test "ForceTrial resampling from 500Hz to 1000Hz" {
  let meta = @core.TrialMetadata::new("Subj03", 500.0, 75.0, "both")
  let samples : Array[@core.ForceSample] = []
  for i = 0; i < 50; i = i + 1 {
    let t = i.to_double() / 500.0
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, 750.0),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
  }
  let trial = @core.ForceTrial::new(meta, samples)
  let resampled = @resample.resample_trial(trial, 1000.0)
  assert_eq(resampled.metadata.sampling_rate, 1000.0)
  assert_true(resampled.length() > 90)
}

///|
test "Akima Spline fitting and evaluation" {
  let xs : Array[Double] = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0]
  let ys : Array[Double] = [0.0, 1.0, 4.0, 9.0, 16.0, 25.0]

  let akima = @resample.fit_akima_spline(xs, ys)
  let val = akima.eval(2.5)
  assert_true((val - 6.25).abs() < 0.2)
}
