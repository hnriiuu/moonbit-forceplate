///|
/// Cubic spline polynomial coefficients for a single interval [x_i, x_{i+1}]:
/// S_i(x) = a_i + b_i * (x - x_i) + c_i * (x - x_i)^2 + d_i * (x - x_i)^3
pub struct SplineSegment {
  x : Double
  a : Double
  b : Double
  c : Double
  d : Double
} derive(Debug, Eq)

///|
/// Evaluates a spline segment at query point `x_val`.
pub fn SplineSegment::eval(self : SplineSegment, x_val : Double) -> Double {
  let dx = x_val - self.x
  self.a + self.b * dx + self.c * dx * dx + self.d * dx * dx * dx
}

///|
/// Cubic Spline Interpolator struct containing ordered knots and polynomial segments.
pub struct CubicSpline {
  segments : Array[SplineSegment]
  knots_x : Array[Double]
} derive(Debug, Eq)

///|
/// Linear interpolation between two 2D points (x0, y0) and (x1, y1).
pub fn lerp(
  x0 : Double,
  y0 : Double,
  x1 : Double,
  y1 : Double,
  x_target : Double,
) -> Double {
  if (x1 - x0).abs() < 0.000000001 {
    y0
  } else {
    y0 + (y1 - y0) * (x_target - x0) / (x1 - x0)
  }
}

///|
/// Evaluates CubicSpline at given `x_val`.
pub fn CubicSpline::eval(self : CubicSpline, x_val : Double) -> Double {
  let n = self.knots_x.length()
  if n == 0 {
    return 0.0
  }
  if n == 1 {
    return self.segments[0].a
  }
  if x_val <= self.knots_x[0] {
    return self.segments[0].a
  }
  if x_val >= self.knots_x[n - 1] {
    let last_seg = self.segments[n - 2]
    return last_seg.eval(x_val)
  }
  // Binary search for knot index
  let mut low = 0
  let mut high = n - 2
  let mut idx = 0
  while low <= high {
    let mid = (low + high) / 2
    if x_val >= self.knots_x[mid] && x_val <= self.knots_x[mid + 1] {
      idx = mid
      break
    } else if x_val < self.knots_x[mid] {
      high = mid - 1
    } else {
      low = mid + 1
    }
  }
  self.segments[idx].eval(x_val)
}

///|
/// Fits a natural cubic spline through discrete points (xs, ys).
pub fn fit_cubic_spline(xs : Array[Double], ys : Array[Double]) -> CubicSpline {
  let n = xs.length()
  if n < 2 {
    let segs : Array[SplineSegment] = [
      {
        x: if n > 0 {
          xs[0]
        } else {
          0.0
        },
        a: if n > 0 {
          ys[0]
        } else {
          0.0
        },
        b: 0.0,
        c: 0.0,
        d: 0.0,
      },
    ]
    return { segments: segs, knots_x: xs }
  }

  let h : Array[Double] = Array::new(capacity=n - 1)
  for i = 0; i < n - 1; i = i + 1 {
    h.push(xs[i + 1] - xs[i])
  }

  let alpha : Array[Double] = Array::new(capacity=n)
  alpha.push(0.0)
  for i = 1; i < n - 1; i = i + 1 {
    let term1 = 3.0 * (ys[i + 1] - ys[i]) / h[i]
    let term2 = 3.0 * (ys[i] - ys[i - 1]) / h[i - 1]
    alpha.push(term1 - term2)
  }

  let l : Array[Double] = Array::new(capacity=n)
  let mu : Array[Double] = Array::new(capacity=n)
  let z : Array[Double] = Array::new(capacity=n)
  for k = 0; k < n; k = k + 1 {
    l.push(0.0)
    mu.push(0.0)
    z.push(0.0)
  }

  l[0] = 1.0
  mu[0] = 0.0
  z[0] = 0.0

  for i = 1; i < n - 1; i = i + 1 {
    l[i] = 2.0 * (xs[i + 1] - xs[i - 1]) - h[i - 1] * mu[i - 1]
    mu[i] = h[i] / l[i]
    z[i] = (alpha[i] - h[i - 1] * z[i - 1]) / l[i]
  }

  let c : Array[Double] = Array::new(capacity=n)
  let b : Array[Double] = Array::new(capacity=n - 1)
  let d : Array[Double] = Array::new(capacity=n - 1)
  for k = 0; k < n; k = k + 1 {
    c.push(0.0)
  }
  for k = 0; k < n - 1; k = k + 1 {
    b.push(0.0)
    d.push(0.0)
  }

  l[n - 1] = 1.0
  z[n - 1] = 0.0
  c[n - 1] = 0.0

  for j = n - 2; j >= 0; j = j - 1 {
    c[j] = z[j] - mu[j] * c[j + 1]
    b[j] = (ys[j + 1] - ys[j]) / h[j] - h[j] * (c[j + 1] + 2.0 * c[j]) / 3.0
    d[j] = (c[j + 1] - c[j]) / (3.0 * h[j])
  }

  let segments : Array[SplineSegment] = Array::new(capacity=n - 1)
  for i = 0; i < n - 1; i = i + 1 {
    segments.push({ x: xs[i], a: ys[i], b: b[i], c: c[i], d: d[i] })
  }

  { segments, knots_x: xs }
}
