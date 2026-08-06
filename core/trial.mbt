///|
/// A continuous sequence of force plate samples representing a single trial recording.
pub struct ForceTrial {
  metadata : TrialMetadata
  samples : Array[ForceSample]
} derive(Debug, Eq)

///|
pub fn ForceTrial::new(
  metadata : TrialMetadata,
  samples : Array[ForceSample],
) -> ForceTrial {
  { metadata, samples }
}

///|
pub fn ForceTrial::length(self : ForceTrial) -> Int {
  self.samples.length()
}

///|
pub fn ForceTrial::duration(self : ForceTrial) -> Double {
  if self.samples.length() < 2 {
    0.0
  } else {
    self.samples[self.samples.length() - 1].timestamp -
    self.samples[0].timestamp
  }
}

///|
pub fn ForceTrial::get_fz(self : ForceTrial) -> Array[Double] {
  let res : Array[Double] = Array::new(capacity=self.samples.length())
  for i = 0; i < self.samples.length(); i = i + 1 {
    res.push(self.samples[i].force.z)
  }
  res
}

///|
pub fn ForceTrial::get_fx(self : ForceTrial) -> Array[Double] {
  let res : Array[Double] = Array::new(capacity=self.samples.length())
  for i = 0; i < self.samples.length(); i = i + 1 {
    res.push(self.samples[i].force.x)
  }
  res
}

///|
pub fn ForceTrial::get_fy(self : ForceTrial) -> Array[Double] {
  let res : Array[Double] = Array::new(capacity=self.samples.length())
  for i = 0; i < self.samples.length(); i = i + 1 {
    res.push(self.samples[i].force.y)
  }
  res
}

///|
pub fn ForceTrial::get_timestamps(self : ForceTrial) -> Array[Double] {
  let res : Array[Double] = Array::new(capacity=self.samples.length())
  for i = 0; i < self.samples.length(); i = i + 1 {
    res.push(self.samples[i].timestamp)
  }
  res
}

///|
pub fn ForceTrial::get_cop_points(self : ForceTrial) -> Array[CoPPoint] {
  let res : Array[CoPPoint] = Array::new(capacity=self.samples.length())
  for i = 0; i < self.samples.length(); i = i + 1 {
    res.push(self.samples[i].cop)
  }
  res
}

///|
pub fn ForceTrial::slice(
  self : ForceTrial,
  start_idx : Int,
  end_idx : Int,
) -> ForceTrial {
  let start = if start_idx < 0 { 0 } else { start_idx }
  let end = if end_idx > self.samples.length() {
    self.samples.length()
  } else {
    end_idx
  }
  let sub : Array[ForceSample] = Array::new(capacity=end - start)
  for i = start; i < end; i = i + 1 {
    sub.push(self.samples[i])
  }
  { metadata: self.metadata, samples: sub }
}

///|
pub fn ForceTrial::apply_calibration(
  self : ForceTrial,
  cal : CalibrationParams,
) -> ForceTrial {
  let calibrated : Array[ForceSample] = Array::new(
    capacity=self.samples.length(),
  )
  for i = 0; i < self.samples.length(); i = i + 1 {
    let s = self.samples[i]
    let fx = (s.force.x - cal.offset_fx) * cal.gain_fx
    let fy = (s.force.y - cal.offset_fy) * cal.gain_fy
    let fz = (s.force.z - cal.offset_fz) * cal.gain_fz
    let cop_x = if fz.abs() > 0.0001 { -s.moment.y / fz } else { 0.0 }
    let cop_y = if fz.abs() > 0.0001 { s.moment.x / fz } else { 0.0 }
    calibrated.push({
      timestamp: s.timestamp,
      force: Vec3::new(fx, fy, fz),
      moment: s.moment,
      cop: CoPPoint::new(cop_x, cop_y),
    })
  }
  { metadata: self.metadata, samples: calibrated }
}

///|
pub fn ForceTrial::zero_tare(
  self : ForceTrial,
  baseline_samples_cnt : Int,
) -> ForceTrial {
  let cnt = if baseline_samples_cnt > self.samples.length() {
    self.samples.length()
  } else {
    baseline_samples_cnt
  }
  if cnt == 0 {
    return self
  }
  let mut sum_fx = 0.0
  let mut sum_fy = 0.0
  let mut sum_fz = 0.0
  for i = 0; i < cnt; i = i + 1 {
    sum_fx = sum_fx + self.samples[i].force.x
    sum_fy = sum_fy + self.samples[i].force.y
    sum_fz = sum_fz + self.samples[i].force.z
  }
  let off_x = sum_fx / cnt.to_double()
  let off_y = sum_fy / cnt.to_double()
  let off_z = sum_fz / cnt.to_double()

  let pared : Array[ForceSample] = Array::new(capacity=self.samples.length())
  for i = 0; i < self.samples.length(); i = i + 1 {
    let s = self.samples[i]
    pared.push({
      timestamp: s.timestamp,
      force: Vec3::new(s.force.x - off_x, s.force.y - off_y, s.force.z - off_z),
      moment: s.moment,
      cop: s.cop,
    })
  }
  { metadata: self.metadata, samples: pared }
}

///|
pub fn compute_mean(arr : Array[Double]) -> Double {
  if arr.length() == 0 {
    0.0
  } else {
    let mut sum = 0.0
    for i = 0; i < arr.length(); i = i + 1 {
      sum = sum + arr[i]
    }
    sum / arr.length().to_double()
  }
}

///|
pub fn compute_std_dev(arr : Array[Double]) -> Double {
  if arr.length() <= 1 {
    0.0
  } else {
    let mean = compute_mean(arr)
    let mut sq_sum = 0.0
    for i = 0; i < arr.length(); i = i + 1 {
      let diff = arr[i] - mean
      sq_sum = sq_sum + diff * diff
    }
    (sq_sum / (arr.length() - 1).to_double()).sqrt()
  }
}

///|
pub fn compute_max(arr : Array[Double]) -> Double {
  if arr.length() == 0 {
    0.0
  } else {
    let mut m = arr[0]
    for i = 1; i < arr.length(); i = i + 1 {
      if arr[i] > m {
        m = arr[i]
      }
    }
    m
  }
}

///|
pub fn compute_min(arr : Array[Double]) -> Double {
  if arr.length() == 0 {
    0.0
  } else {
    let mut m = arr[0]
    for i = 1; i < arr.length(); i = i + 1 {
      if arr[i] < m {
        m = arr[i]
      }
    }
    m
  }
}
