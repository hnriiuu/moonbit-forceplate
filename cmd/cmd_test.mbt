///|
test "Synthetic CMJ generation" {
  let trial = @cmd.generate_synthetic_cmj_trial("Subj12", 70.0, 1000.0)
  assert_true(trial.length() > 1000)
}

///|
test "Synthetic sway generation" {
  let trial = @cmd.generate_synthetic_sway_trial("Subj13", 5.0, 100.0)
  assert_eq(trial.length(), 500)
}
