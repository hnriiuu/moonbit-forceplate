///|
test "CSV trial export formatting" {
  let meta = @core.TrialMetadata::new("Subj10", 1000.0, 70.0, "both")
  let samples : Array[@core.ForceSample] = [
    @core.ForceSample::new(
      0.0,
      @core.Vec3::new(1.0, 2.0, 700.0),
      @core.Vec3::zero(),
      @core.CoPPoint::new(0.5, 0.5),
    ),
  ]
  let trial = @core.ForceTrial::new(meta, samples)
  let csv = @export.export_trial_to_csv(trial)

  assert_true(csv.contains("timestamp,fx,fy,fz"))
  assert_true(csv.contains("700"))
}

///|
test "ASCII sparkline generation" {
  let sig : Array[Double] = [
    0.0, 10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0,
  ]
  let spark = @export.generate_ascii_sparkline(sig, 10)

  assert_eq(spark.length(), 10)
}

///|
test "CMJ ASCII report formatting" {
  let meta = @core.TrialMetadata::new("Subj11", 1000.0, 70.0, "both")
  let samples : Array[@core.ForceSample] = []
  let bw_n = 70.0 * 9.80665
  for i = 0; i < 200; i = i + 1 {
    let t = i.to_double() / 1000.0
    samples.push(
      @core.ForceSample::new(
        t,
        @core.Vec3::new(0.0, 0.0, bw_n),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
  }
  let trial = @core.ForceTrial::new(meta, samples)
  let cmj = @jump.analyze_cmj_trial(trial, 70.0)
  let rpt = @export.format_cmj_ascii_report(trial, cmj)

  assert_true(rpt.contains("FORCE PLATE BIOMECHANICS REPORT"))
  assert_true(rpt.contains("Subj11"))
}
