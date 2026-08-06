///|
/// Orientation helper for Graham Scan: returns >0 for CCW, <0 for CW, 0 for collinear.
fn ccw_orientation(
  p1 : @core.CoPPoint,
  p2 : @core.CoPPoint,
  p3 : @core.CoPPoint,
) -> Double {
  (p2.x - p1.x) * (p3.y - p1.y) - (p2.y - p1.y) * (p3.x - p1.x)
}

///|
/// Computes 2D Convex Hull Area of Center of Pressure (COP) trace using Monotone Chain / Graham algorithm.
pub fn compute_cop_convex_hull_area(
  cop_points : Array[@core.CoPPoint],
) -> Double {
  let n = cop_points.length()
  if n < 3 {
    return 0.0
  }

  // Sort points primarily by x, secondarily by y
  let pts : Array[@core.CoPPoint] = Array::new(capacity=n)
  for i = 0; i < n; i = i + 1 {
    pts.push(cop_points[i])
  }
  pts.sort_by(fn(a, b) {
    if a.x != b.x {
      if a.x < b.x {
        -1
      } else {
        1
      }
    } else if a.y < b.y {
      -1
    } else if a.y > b.y {
      1
    } else {
      0
    }
  })

  // Lower hull
  let lower : Array[@core.CoPPoint] = Array::new(capacity=n)
  for i = 0; i < n; i = i + 1 {
    while lower.length() >= 2 &&
          ccw_orientation(
            lower[lower.length() - 2],
            lower[lower.length() - 1],
            pts[i],
          ) <=
          0.0 {
      let _ = lower.pop()
    }
    lower.push(pts[i])
  }

  // Upper hull
  let upper : Array[@core.CoPPoint] = Array::new(capacity=n)
  for i = n - 1; i >= 0; i = i - 1 {
    while upper.length() >= 2 &&
          ccw_orientation(
            upper[upper.length() - 2],
            upper[upper.length() - 1],
            pts[i],
          ) <=
          0.0 {
      let _ = upper.pop()
    }
    upper.push(pts[i])
  }

  // Combine hulls (remove last point of each stack because it's duplicated)
  let hull : Array[@core.CoPPoint] = Array::new(
    capacity=lower.length() + upper.length(),
  )
  for i = 0; i < lower.length() - 1; i = i + 1 {
    hull.push(lower[i])
  }
  for i = 0; i < upper.length() - 1; i = i + 1 {
    hull.push(upper[i])
  }

  let h_len = hull.length()
  if h_len < 3 {
    return 0.0
  }

  // Polygon area via Shoelace formula
  let mut area_sum = 0.0
  for i = 0; i < h_len; i = i + 1 {
    let p1 = hull[i]
    let p2 = hull[(i + 1) % h_len]
    area_sum = area_sum + (p1.x * p2.y - p2.x * p1.y)
  }

  (area_sum / 2.0).abs()
}
