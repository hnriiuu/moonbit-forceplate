///|
/// Structure holding complete static posturography and COP sway metrics.
pub struct SwayReport {
  total_path_length_mm : Double
  mean_velocity_mm_s : Double
  ap_range_mm : Double
  ap_mean_mm : Double
  ap_std_dev_mm : Double
  ml_range_mm : Double
  ml_mean_mm : Double
  ml_std_dev_mm : Double
  ellipse_95_area_mm2 : Double
} derive(Debug, Eq)

///|
/// Computes total path length (mm or m depending on COP units) traveled by COP.
pub fn compute_cop_path_length(cop_points : Array[@core.CoPPoint]) -> Double {
  let n = cop_points.length()
  if n < 2 {
    return 0.0
  }
  let mut length = 0.0
  for i = 0; i < n - 1; i = i + 1 {
    length = length + cop_points[i].distance_to(cop_points[i + 1])
  }
  length
}

///|
/// Extracts Anteroposterior (AP, Y axis) coordinate sequence from COP points.
pub fn extract_ap_series(cop_points : Array[@core.CoPPoint]) -> Array[Double] {
  let res : Array[Double] = Array::new(capacity=cop_points.length())
  for i = 0; i < cop_points.length(); i = i + 1 {
    res.push(cop_points[i].y)
  }
  res
}

///|
/// Extracts Mediolateral (ML, X axis) coordinate sequence from COP points.
pub fn extract_ml_series(cop_points : Array[@core.CoPPoint]) -> Array[Double] {
  let res : Array[Double] = Array::new(capacity=cop_points.length())
  for i = 0; i < cop_points.length(); i = i + 1 {
    res.push(cop_points[i].x)
  }
  res
}
