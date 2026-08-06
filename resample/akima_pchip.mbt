///|
/// Akima Spline polynomial segment.
pub struct AkimaSegment {
  x : Double
  a : Double
  b : Double
  c : Double
  d : Double
} derive(Debug, Eq)

///|
/// Evaluates Akima spline segment at `x_val`.
pub fn AkimaSegment::eval(self : AkimaSegment, x_val : Double) -> Double {
  let dx = x_val - self.x
  self.a + self.b * dx + self.c * dx * dx + self.d * dx * dx * dx
}

///|
/// Akima Spline Interpolator struct.
pub struct AkimaSpline {
  segments : Array[AkimaSegment]
  knots_x : Array[Double]
} derive(Debug, Eq)

///|
/// Fits an Akima spline through discrete points (xs, ys).
/// Akima splines prevent unphysical oscillations/overshoots near abrupt force transients.
pub fn fit_akima_spline(xs : Array[Double], ys : Array[Double]) -> AkimaSpline {
  let n = xs.length()
  if n < 5 {
    // Fallback to cubic spline for short sequences
    let cs = fit_cubic_spline(xs, ys)
    let segs : Array[AkimaSegment] = Array::new(capacity=cs.segments.length())
    for i = 0; i < cs.segments.length(); i = i + 1 {
      let s = cs.segments[i]
      segs.push({ x: s.x, a: s.a, b: s.b, c: s.c, d: s.d })
    }
    return { segments: segs, knots_x: xs }
  }

  // Secant slopes m_i = (y_{i+1} - y_i) / (x_{i+1} - x_i)
  let m : Array[Double] = Array::new(capacity=n + 3)
  for i = 0; i < n - 1; i = i + 1 {
    m.push((ys[i + 1] - ys[i]) / (xs[i + 1] - xs[i]))
  }

  // Extend slopes at boundaries
  let m_minus1 = 2.0 * m[0] - m[1]
  let m_minus2 = 2.0 * m_minus1 - m[0]
  let m_n = 2.0 * m[n - 2] - m[n - 3]
  let m_nplus1 = 2.0 * m_n - m[n - 2]

  let slopes : Array[Double] = Array::new(capacity=n + 3)
  slopes.push(m_minus2)
  slopes.push(m_minus1)
  for i = 0; i < n - 1; i = i + 1 {
    slopes.push(m[i])
  }
  slopes.push(m_n)
  slopes.push(m_nplus1)

  // Derivatives t_i at each knot i
  let t : Array[Double] = Array::new(capacity=n)
  for i = 0; i < n; i = i + 1 {
    let m1 = slopes[i]
    let m2 = slopes[i + 1]
    let m3 = slopes[i + 2]
    let m4 = slopes[i + 3]

    let w1 = (m4 - m3).abs()
    let w2 = (m2 - m1).abs()

    let deriv = if (w1 + w2).abs() < 0.000000001 {
      (m2 + m3) / 2.0
    } else {
      (w1 * m2 + w2 * m3) / (w1 + w2)
    }
    t.push(deriv)
  }

  let segments : Array[AkimaSegment] = Array::new(capacity=n - 1)
  for i = 0; i < n - 1; i = i + 1 {
    let dx = xs[i + 1] - xs[i]
    let a = ys[i]
    let b = t[i]
    let c = (3.0 * m[i] - 2.0 * t[i] - t[i + 1]) / dx
    let d = (t[i] + t[i + 1] - 2.0 * m[i]) / (dx * dx)
    segments.push({ x: xs[i], a, b, c, d })
  }

  { segments, knots_x: xs }
}

///|
/// Evaluates AkimaSpline at `x_val`.
pub fn AkimaSpline::eval(self : AkimaSpline, x_val : Double) -> Double {
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
    let last = self.segments[n - 2]
    return last.eval(x_val)
  }
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
