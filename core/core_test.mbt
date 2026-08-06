///|
test "Vec3 vector math operations" {
  let v1 = @core.Vec3::new(10.0, 20.0, 30.0)
  let v2 = @core.Vec3::new(2.0, 4.0, 6.0)
  let add_res = v1.add(v2)
  assert_eq(add_res.x, 12.0)
  assert_eq(add_res.y, 24.0)
  assert_eq(add_res.z, 36.0)

  let sub_res = v1.sub(v2)
  assert_eq(sub_res.x, 8.0)
  assert_eq(sub_res.y, 16.0)
  assert_eq(sub_res.z, 24.0)

  let scaled = v2.scale(2.5)
  assert_eq(scaled.x, 5.0)
  assert_eq(scaled.y, 10.0)
  assert_eq(scaled.z, 15.0)

  let dot_val = v1.dot(v2)
  assert_eq(dot_val, 20.0 + 80.0 + 180.0)
}

///|
test "CoPPoint distance and zero" {
  let p1 = @core.CoPPoint::new(0.0, 0.0)
  let p2 = @core.CoPPoint::new(3.0, 4.0)
  assert_eq(p1.distance_to(p2), 5.0)
}

///|
test "ForceTrial creation, slicing and statistics" {
  let meta = @core.TrialMetadata::new("Subject01", 1000.0, 70.0, "both")
  let samples : Array[@core.ForceSample] = []
  for i = 0; i < 100; i = i + 1 {
    let t = i.to_double() / 1000.0
    let fz = 700.0 + i.to_double() * 2.0
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, fz),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
  }
  let trial = @core.ForceTrial::new(meta, samples)
  assert_eq(trial.length(), 100)

  let fz_arr = trial.get_fz()
  assert_eq(fz_arr.length(), 100)
  let mean_fz = @core.compute_mean(fz_arr)
  assert_eq(mean_fz, 799.0)

  let sliced = trial.slice(10, 30)
  assert_eq(sliced.length(), 20)
}

///|
test "ForceTrial calibration and zero tare" {
  let meta = @core.TrialMetadata::new("Subj02", 1000.0, 80.0, "both")
  let samples : Array[@core.ForceSample] = [
    @core.ForceSample::new(
      0.0,
      @core.Vec3::new(10.0, 10.0, 800.0),
      @core.Vec3::zero(),
      @core.CoPPoint::zero(),
    ),
    @core.ForceSample::new(
      0.001,
      @core.Vec3::new(10.0, 10.0, 800.0),
      @core.Vec3::zero(),
      @core.CoPPoint::zero(),
    ),
  ]
  let trial = @core.ForceTrial::new(meta, samples)
  let tared = trial.zero_tare(2)
  let fz_tared = tared.get_fz()
  assert_eq(fz_tared[0], 0.0)
  assert_eq(fz_tared[1], 0.0)
}
