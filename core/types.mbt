///|
/// Represents a 3D vector for ground reaction forces, centers, or moments.
pub struct Vec3 {
  x : Double
  y : Double
  z : Double
} derive(Debug, Eq)

///|
pub fn Vec3::new(x : Double, y : Double, z : Double) -> Vec3 {
  { x, y, z }
}

///|
pub fn Vec3::zero() -> Vec3 {
  { x: 0.0, y: 0.0, z: 0.0 }
}

///|
pub fn Vec3::add(self : Vec3, other : Vec3) -> Vec3 {
  { x: self.x + other.x, y: self.y + other.y, z: self.z + other.z }
}

///|
pub fn Vec3::sub(self : Vec3, other : Vec3) -> Vec3 {
  { x: self.x - other.x, y: self.y - other.y, z: self.z - other.z }
}

///|
pub fn Vec3::scale(self : Vec3, factor : Double) -> Vec3 {
  { x: self.x * factor, y: self.y * factor, z: self.z * factor }
}

///|
pub fn Vec3::magnitude(self : Vec3) -> Double {
  (self.x * self.x + self.y * self.y + self.z * self.z).sqrt()
}

///|
pub fn Vec3::dot(self : Vec3, other : Vec3) -> Double {
  self.x * other.x + self.y * other.y + self.z * other.z
}

///|
/// Center of Pressure (COP) 2D coordinates on the force plate surface.
pub struct CoPPoint {
  x : Double
  y : Double
} derive(Debug, Eq)

///|
pub fn CoPPoint::new(x : Double, y : Double) -> CoPPoint {
  { x, y }
}

///|
pub fn CoPPoint::zero() -> CoPPoint {
  { x: 0.0, y: 0.0 }
}

///|
pub fn CoPPoint::distance_to(self : CoPPoint, other : CoPPoint) -> Double {
  let dx = self.x - other.x
  let dy = self.y - other.y
  (dx * dx + dy * dy).sqrt()
}

///|
/// Single time-step multichannel force plate sample frame.
pub struct ForceSample {
  timestamp : Double
  force : Vec3
  moment : Vec3
  cop : CoPPoint
} derive(Debug, Eq)

///|
pub fn ForceSample::new(
  timestamp : Double,
  force : Vec3,
  moment : Vec3,
  cop : CoPPoint,
) -> ForceSample {
  { timestamp, force, moment, cop }
}

///|
/// Calibration and tare parameters for multi-axis force plate sensors.
pub struct CalibrationParams {
  gain_fx : Double
  gain_fy : Double
  gain_fz : Double
  offset_fx : Double
  offset_fy : Double
  offset_fz : Double
  plate_origin_z : Double
} derive(Debug, Eq)

///|
pub fn CalibrationParams::default() -> CalibrationParams {
  {
    gain_fx: 1.0,
    gain_fy: 1.0,
    gain_fz: 1.0,
    offset_fx: 0.0,
    offset_fy: 0.0,
    offset_fz: 0.0,
    plate_origin_z: 0.0,
  }
}

///|
/// Trial metadata describing sampling rate, subject body mass estimate, and side.
pub struct TrialMetadata {
  subject_id : String
  sampling_rate : Double
  nominal_body_mass : Double
  side : String
} derive(Debug, Eq)

///|
pub fn TrialMetadata::new(
  subject_id : String,
  sampling_rate : Double,
  nominal_body_mass : Double,
  side : String,
) -> TrialMetadata {
  { subject_id, sampling_rate, nominal_body_mass, side }
}
