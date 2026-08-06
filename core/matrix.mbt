///|
/// Represents a 3x3 Matrix for 3D coordinate transformations and rotation.
pub struct Matrix3x3 {
  m00 : Double
  m01 : Double
  m02 : Double
  m10 : Double
  m11 : Double
  m12 : Double
  m20 : Double
  m21 : Double
  m22 : Double
} derive(Debug, Eq)

///|
pub fn Matrix3x3::identity() -> Matrix3x3 {
  {
    m00: 1.0,
    m01: 0.0,
    m02: 0.0,
    m10: 0.0,
    m11: 1.0,
    m12: 0.0,
    m20: 0.0,
    m21: 0.0,
    m22: 1.0,
  }
}

///|
pub fn Matrix3x3::new(
  m00 : Double,
  m01 : Double,
  m02 : Double,
  m10 : Double,
  m11 : Double,
  m12 : Double,
  m20 : Double,
  m21 : Double,
  m22 : Double,
) -> Matrix3x3 {
  { m00, m01, m02, m10, m11, m12, m20, m21, m22 }
}

///|
pub fn Matrix3x3::transform_vec(self : Matrix3x3, v : Vec3) -> Vec3 {
  let x = self.m00 * v.x + self.m01 * v.y + self.m02 * v.z
  let y = self.m10 * v.x + self.m11 * v.y + self.m12 * v.z
  let z = self.m20 * v.x + self.m21 * v.y + self.m22 * v.z
  Vec3::new(x, y, z)
}

///|
/// Computes determinant of a 3x3 matrix.
pub fn Matrix3x3::determinant(self : Matrix3x3) -> Double {
  self.m00 * (self.m11 * self.m22 - self.m12 * self.m21) -
  self.m01 * (self.m10 * self.m22 - self.m12 * self.m20) +
  self.m02 * (self.m10 * self.m21 - self.m11 * self.m20)
}

///|
/// Inverts a 3x3 matrix if non-singular.
pub fn Matrix3x3::inverse(self : Matrix3x3) -> Matrix3x3 {
  let det = self.determinant()
  if det.abs() < 0.000000001 {
    return Matrix3x3::identity()
  }
  let inv_det = 1.0 / det

  let i00 = (self.m11 * self.m22 - self.m12 * self.m21) * inv_det
  let i01 = (self.m02 * self.m21 - self.m01 * self.m22) * inv_det
  let i02 = (self.m01 * self.m12 - self.m02 * self.m11) * inv_det

  let i10 = (self.m12 * self.m20 - self.m10 * self.m22) * inv_det
  let i11 = (self.m00 * self.m22 - self.m02 * self.m20) * inv_det
  let i12 = (self.m02 * self.m10 - self.m00 * self.m12) * inv_det

  let i20 = (self.m10 * self.m21 - self.m11 * self.m20) * inv_det
  let i21 = (self.m01 * self.m10 - self.m00 * self.m21) * inv_det
  let i22 = (self.m00 * self.m11 - self.m01 * self.m10) * inv_det

  Matrix3x3::new(i00, i01, i02, i10, i11, i12, i20, i21, i22)
}

///|
/// Computes Root Mean Square (RMS) of an array.
pub fn compute_rms(arr : Array[Double]) -> Double {
  let n = arr.length()
  if n == 0 {
    return 0.0
  }
  let mut sum_sq = 0.0
  for i = 0; i < n; i = i + 1 {
    sum_sq = sum_sq + arr[i] * arr[i]
  }
  (sum_sq / n.to_double()).sqrt()
}

///|
/// Computes Skewness of an array distribution.
pub fn compute_skewness(arr : Array[Double]) -> Double {
  let n = arr.length()
  if n <= 2 {
    return 0.0
  }
  let mean = compute_mean(arr)
  let sd = compute_std_dev(arr)
  if sd < 0.000000001 {
    return 0.0
  }
  let mut sum_cube = 0.0
  for i = 0; i < n; i = i + 1 {
    let diff = (arr[i] - mean) / sd
    sum_cube = sum_cube + diff * diff * diff
  }
  sum_cube / n.to_double()
}

///|
/// Computes Kurtosis of an array distribution.
pub fn compute_kurtosis(arr : Array[Double]) -> Double {
  let n = arr.length()
  if n <= 3 {
    return 0.0
  }
  let mean = compute_mean(arr)
  let sd = compute_std_dev(arr)
  if sd < 0.000000001 {
    return 0.0
  }
  let mut sum_fourth = 0.0
  for i = 0; i < n; i = i + 1 {
    let diff = (arr[i] - mean) / sd
    sum_fourth = sum_fourth + diff * diff * diff * diff
  }
  sum_fourth / n.to_double() - 3.0
}
