///|
/// Additional fixed-window robust kernels for allocation-sensitive serving.
pub fn fixed_median_001(values : Array[Double]) -> Double {
  if values.length() < 1 {
    abort("fixed_median_001: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 1)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_002(values : Array[Double]) -> Double {
  if values.length() < 2 {
    abort("fixed_median_002: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 2)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_003(values : Array[Double]) -> Double {
  if values.length() < 3 {
    abort("fixed_median_003: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 3)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_004(values : Array[Double]) -> Double {
  if values.length() < 4 {
    abort("fixed_median_004: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 4)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_005(values : Array[Double]) -> Double {
  if values.length() < 5 {
    abort("fixed_median_005: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 5)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_006(values : Array[Double]) -> Double {
  if values.length() < 6 {
    abort("fixed_median_006: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 6)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_007(values : Array[Double]) -> Double {
  if values.length() < 7 {
    abort("fixed_median_007: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 7)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_008(values : Array[Double]) -> Double {
  if values.length() < 8 {
    abort("fixed_median_008: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 8)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_009(values : Array[Double]) -> Double {
  if values.length() < 9 {
    abort("fixed_median_009: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 9)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_010(values : Array[Double]) -> Double {
  if values.length() < 10 {
    abort("fixed_median_010: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 10)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_011(values : Array[Double]) -> Double {
  if values.length() < 11 {
    abort("fixed_median_011: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 11)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_012(values : Array[Double]) -> Double {
  if values.length() < 12 {
    abort("fixed_median_012: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 12)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_013(values : Array[Double]) -> Double {
  if values.length() < 13 {
    abort("fixed_median_013: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 13)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_014(values : Array[Double]) -> Double {
  if values.length() < 14 {
    abort("fixed_median_014: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 14)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_015(values : Array[Double]) -> Double {
  if values.length() < 15 {
    abort("fixed_median_015: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 15)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_016(values : Array[Double]) -> Double {
  if values.length() < 16 {
    abort("fixed_median_016: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 16)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_017(values : Array[Double]) -> Double {
  if values.length() < 17 {
    abort("fixed_median_017: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 17)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_018(values : Array[Double]) -> Double {
  if values.length() < 18 {
    abort("fixed_median_018: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 18)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_019(values : Array[Double]) -> Double {
  if values.length() < 19 {
    abort("fixed_median_019: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 19)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_020(values : Array[Double]) -> Double {
  if values.length() < 20 {
    abort("fixed_median_020: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 20)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_021(values : Array[Double]) -> Double {
  if values.length() < 21 {
    abort("fixed_median_021: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 21)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_022(values : Array[Double]) -> Double {
  if values.length() < 22 {
    abort("fixed_median_022: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 22)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_023(values : Array[Double]) -> Double {
  if values.length() < 23 {
    abort("fixed_median_023: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 23)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_024(values : Array[Double]) -> Double {
  if values.length() < 24 {
    abort("fixed_median_024: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 24)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_025(values : Array[Double]) -> Double {
  if values.length() < 25 {
    abort("fixed_median_025: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 25)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_026(values : Array[Double]) -> Double {
  if values.length() < 26 {
    abort("fixed_median_026: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 26)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_027(values : Array[Double]) -> Double {
  if values.length() < 27 {
    abort("fixed_median_027: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 27)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_028(values : Array[Double]) -> Double {
  if values.length() < 28 {
    abort("fixed_median_028: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 28)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_029(values : Array[Double]) -> Double {
  if values.length() < 29 {
    abort("fixed_median_029: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 29)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_030(values : Array[Double]) -> Double {
  if values.length() < 30 {
    abort("fixed_median_030: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 30)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_031(values : Array[Double]) -> Double {
  if values.length() < 31 {
    abort("fixed_median_031: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 31)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_032(values : Array[Double]) -> Double {
  if values.length() < 32 {
    abort("fixed_median_032: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 32)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_033(values : Array[Double]) -> Double {
  if values.length() < 33 {
    abort("fixed_median_033: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 33)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_034(values : Array[Double]) -> Double {
  if values.length() < 34 {
    abort("fixed_median_034: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 34)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_035(values : Array[Double]) -> Double {
  if values.length() < 35 {
    abort("fixed_median_035: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 35)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_036(values : Array[Double]) -> Double {
  if values.length() < 36 {
    abort("fixed_median_036: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 36)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_037(values : Array[Double]) -> Double {
  if values.length() < 37 {
    abort("fixed_median_037: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 37)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_038(values : Array[Double]) -> Double {
  if values.length() < 38 {
    abort("fixed_median_038: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 38)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_039(values : Array[Double]) -> Double {
  if values.length() < 39 {
    abort("fixed_median_039: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 39)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_040(values : Array[Double]) -> Double {
  if values.length() < 40 {
    abort("fixed_median_040: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 40)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_041(values : Array[Double]) -> Double {
  if values.length() < 41 {
    abort("fixed_median_041: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 41)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_042(values : Array[Double]) -> Double {
  if values.length() < 42 {
    abort("fixed_median_042: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 42)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_043(values : Array[Double]) -> Double {
  if values.length() < 43 {
    abort("fixed_median_043: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 43)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_044(values : Array[Double]) -> Double {
  if values.length() < 44 {
    abort("fixed_median_044: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 44)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_045(values : Array[Double]) -> Double {
  if values.length() < 45 {
    abort("fixed_median_045: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 45)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_046(values : Array[Double]) -> Double {
  if values.length() < 46 {
    abort("fixed_median_046: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 46)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_047(values : Array[Double]) -> Double {
  if values.length() < 47 {
    abort("fixed_median_047: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 47)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_048(values : Array[Double]) -> Double {
  if values.length() < 48 {
    abort("fixed_median_048: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 48)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_049(values : Array[Double]) -> Double {
  if values.length() < 49 {
    abort("fixed_median_049: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 49)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_050(values : Array[Double]) -> Double {
  if values.length() < 50 {
    abort("fixed_median_050: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 50)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_051(values : Array[Double]) -> Double {
  if values.length() < 51 {
    abort("fixed_median_051: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 51)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_052(values : Array[Double]) -> Double {
  if values.length() < 52 {
    abort("fixed_median_052: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 52)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_053(values : Array[Double]) -> Double {
  if values.length() < 53 {
    abort("fixed_median_053: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 53)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_054(values : Array[Double]) -> Double {
  if values.length() < 54 {
    abort("fixed_median_054: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 54)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_055(values : Array[Double]) -> Double {
  if values.length() < 55 {
    abort("fixed_median_055: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 55)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_056(values : Array[Double]) -> Double {
  if values.length() < 56 {
    abort("fixed_median_056: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 56)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_057(values : Array[Double]) -> Double {
  if values.length() < 57 {
    abort("fixed_median_057: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 57)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_058(values : Array[Double]) -> Double {
  if values.length() < 58 {
    abort("fixed_median_058: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 58)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_059(values : Array[Double]) -> Double {
  if values.length() < 59 {
    abort("fixed_median_059: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 59)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_060(values : Array[Double]) -> Double {
  if values.length() < 60 {
    abort("fixed_median_060: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 60)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_061(values : Array[Double]) -> Double {
  if values.length() < 61 {
    abort("fixed_median_061: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 61)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_062(values : Array[Double]) -> Double {
  if values.length() < 62 {
    abort("fixed_median_062: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 62)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_063(values : Array[Double]) -> Double {
  if values.length() < 63 {
    abort("fixed_median_063: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 63)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_064(values : Array[Double]) -> Double {
  if values.length() < 64 {
    abort("fixed_median_064: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 64)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_065(values : Array[Double]) -> Double {
  if values.length() < 65 {
    abort("fixed_median_065: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 65)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_066(values : Array[Double]) -> Double {
  if values.length() < 66 {
    abort("fixed_median_066: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 66)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_067(values : Array[Double]) -> Double {
  if values.length() < 67 {
    abort("fixed_median_067: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 67)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_068(values : Array[Double]) -> Double {
  if values.length() < 68 {
    abort("fixed_median_068: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 68)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_069(values : Array[Double]) -> Double {
  if values.length() < 69 {
    abort("fixed_median_069: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 69)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_070(values : Array[Double]) -> Double {
  if values.length() < 70 {
    abort("fixed_median_070: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 70)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_071(values : Array[Double]) -> Double {
  if values.length() < 71 {
    abort("fixed_median_071: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 71)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_072(values : Array[Double]) -> Double {
  if values.length() < 72 {
    abort("fixed_median_072: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 72)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_073(values : Array[Double]) -> Double {
  if values.length() < 73 {
    abort("fixed_median_073: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 73)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_074(values : Array[Double]) -> Double {
  if values.length() < 74 {
    abort("fixed_median_074: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 74)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_075(values : Array[Double]) -> Double {
  if values.length() < 75 {
    abort("fixed_median_075: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 75)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_076(values : Array[Double]) -> Double {
  if values.length() < 76 {
    abort("fixed_median_076: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 76)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_077(values : Array[Double]) -> Double {
  if values.length() < 77 {
    abort("fixed_median_077: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 77)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_078(values : Array[Double]) -> Double {
  if values.length() < 78 {
    abort("fixed_median_078: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 78)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_079(values : Array[Double]) -> Double {
  if values.length() < 79 {
    abort("fixed_median_079: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 79)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_080(values : Array[Double]) -> Double {
  if values.length() < 80 {
    abort("fixed_median_080: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 80)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_081(values : Array[Double]) -> Double {
  if values.length() < 81 {
    abort("fixed_median_081: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 81)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_082(values : Array[Double]) -> Double {
  if values.length() < 82 {
    abort("fixed_median_082: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 82)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_083(values : Array[Double]) -> Double {
  if values.length() < 83 {
    abort("fixed_median_083: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 83)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_084(values : Array[Double]) -> Double {
  if values.length() < 84 {
    abort("fixed_median_084: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 84)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_085(values : Array[Double]) -> Double {
  if values.length() < 85 {
    abort("fixed_median_085: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 85)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_086(values : Array[Double]) -> Double {
  if values.length() < 86 {
    abort("fixed_median_086: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 86)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_087(values : Array[Double]) -> Double {
  if values.length() < 87 {
    abort("fixed_median_087: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 87)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_088(values : Array[Double]) -> Double {
  if values.length() < 88 {
    abort("fixed_median_088: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 88)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_089(values : Array[Double]) -> Double {
  if values.length() < 89 {
    abort("fixed_median_089: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 89)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_090(values : Array[Double]) -> Double {
  if values.length() < 90 {
    abort("fixed_median_090: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 90)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_091(values : Array[Double]) -> Double {
  if values.length() < 91 {
    abort("fixed_median_091: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 91)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_092(values : Array[Double]) -> Double {
  if values.length() < 92 {
    abort("fixed_median_092: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 92)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_093(values : Array[Double]) -> Double {
  if values.length() < 93 {
    abort("fixed_median_093: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 93)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_094(values : Array[Double]) -> Double {
  if values.length() < 94 {
    abort("fixed_median_094: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 94)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_095(values : Array[Double]) -> Double {
  if values.length() < 95 {
    abort("fixed_median_095: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 95)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_096(values : Array[Double]) -> Double {
  if values.length() < 96 {
    abort("fixed_median_096: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 96)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_097(values : Array[Double]) -> Double {
  if values.length() < 97 {
    abort("fixed_median_097: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 97)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_098(values : Array[Double]) -> Double {
  if values.length() < 98 {
    abort("fixed_median_098: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 98)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_099(values : Array[Double]) -> Double {
  if values.length() < 99 {
    abort("fixed_median_099: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 99)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_100(values : Array[Double]) -> Double {
  if values.length() < 100 {
    abort("fixed_median_100: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 100)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_101(values : Array[Double]) -> Double {
  if values.length() < 101 {
    abort("fixed_median_101: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 101)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_102(values : Array[Double]) -> Double {
  if values.length() < 102 {
    abort("fixed_median_102: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 102)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_103(values : Array[Double]) -> Double {
  if values.length() < 103 {
    abort("fixed_median_103: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 103)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_104(values : Array[Double]) -> Double {
  if values.length() < 104 {
    abort("fixed_median_104: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 104)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_105(values : Array[Double]) -> Double {
  if values.length() < 105 {
    abort("fixed_median_105: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 105)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_106(values : Array[Double]) -> Double {
  if values.length() < 106 {
    abort("fixed_median_106: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 106)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_107(values : Array[Double]) -> Double {
  if values.length() < 107 {
    abort("fixed_median_107: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 107)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_108(values : Array[Double]) -> Double {
  if values.length() < 108 {
    abort("fixed_median_108: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 108)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_109(values : Array[Double]) -> Double {
  if values.length() < 109 {
    abort("fixed_median_109: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 109)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_110(values : Array[Double]) -> Double {
  if values.length() < 110 {
    abort("fixed_median_110: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 110)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_111(values : Array[Double]) -> Double {
  if values.length() < 111 {
    abort("fixed_median_111: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 111)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_112(values : Array[Double]) -> Double {
  if values.length() < 112 {
    abort("fixed_median_112: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 112)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_113(values : Array[Double]) -> Double {
  if values.length() < 113 {
    abort("fixed_median_113: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 113)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_114(values : Array[Double]) -> Double {
  if values.length() < 114 {
    abort("fixed_median_114: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 114)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_115(values : Array[Double]) -> Double {
  if values.length() < 115 {
    abort("fixed_median_115: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 115)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_116(values : Array[Double]) -> Double {
  if values.length() < 116 {
    abort("fixed_median_116: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 116)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_117(values : Array[Double]) -> Double {
  if values.length() < 117 {
    abort("fixed_median_117: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 117)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_118(values : Array[Double]) -> Double {
  if values.length() < 118 {
    abort("fixed_median_118: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 118)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_119(values : Array[Double]) -> Double {
  if values.length() < 119 {
    abort("fixed_median_119: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 119)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_120(values : Array[Double]) -> Double {
  if values.length() < 120 {
    abort("fixed_median_120: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 120)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_121(values : Array[Double]) -> Double {
  if values.length() < 121 {
    abort("fixed_median_121: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 121)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_122(values : Array[Double]) -> Double {
  if values.length() < 122 {
    abort("fixed_median_122: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 122)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_123(values : Array[Double]) -> Double {
  if values.length() < 123 {
    abort("fixed_median_123: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 123)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_124(values : Array[Double]) -> Double {
  if values.length() < 124 {
    abort("fixed_median_124: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 124)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_125(values : Array[Double]) -> Double {
  if values.length() < 125 {
    abort("fixed_median_125: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 125)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_126(values : Array[Double]) -> Double {
  if values.length() < 126 {
    abort("fixed_median_126: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 126)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_127(values : Array[Double]) -> Double {
  if values.length() < 127 {
    abort("fixed_median_127: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 127)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_128(values : Array[Double]) -> Double {
  if values.length() < 128 {
    abort("fixed_median_128: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 128)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_129(values : Array[Double]) -> Double {
  if values.length() < 129 {
    abort("fixed_median_129: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 129)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_130(values : Array[Double]) -> Double {
  if values.length() < 130 {
    abort("fixed_median_130: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 130)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_131(values : Array[Double]) -> Double {
  if values.length() < 131 {
    abort("fixed_median_131: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 131)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_132(values : Array[Double]) -> Double {
  if values.length() < 132 {
    abort("fixed_median_132: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 132)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_133(values : Array[Double]) -> Double {
  if values.length() < 133 {
    abort("fixed_median_133: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 133)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_134(values : Array[Double]) -> Double {
  if values.length() < 134 {
    abort("fixed_median_134: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 134)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_135(values : Array[Double]) -> Double {
  if values.length() < 135 {
    abort("fixed_median_135: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 135)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_136(values : Array[Double]) -> Double {
  if values.length() < 136 {
    abort("fixed_median_136: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 136)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_137(values : Array[Double]) -> Double {
  if values.length() < 137 {
    abort("fixed_median_137: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 137)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_138(values : Array[Double]) -> Double {
  if values.length() < 138 {
    abort("fixed_median_138: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 138)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_139(values : Array[Double]) -> Double {
  if values.length() < 139 {
    abort("fixed_median_139: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 139)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_140(values : Array[Double]) -> Double {
  if values.length() < 140 {
    abort("fixed_median_140: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 140)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_141(values : Array[Double]) -> Double {
  if values.length() < 141 {
    abort("fixed_median_141: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 141)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_142(values : Array[Double]) -> Double {
  if values.length() < 142 {
    abort("fixed_median_142: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 142)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_143(values : Array[Double]) -> Double {
  if values.length() < 143 {
    abort("fixed_median_143: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 143)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_144(values : Array[Double]) -> Double {
  if values.length() < 144 {
    abort("fixed_median_144: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 144)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_145(values : Array[Double]) -> Double {
  if values.length() < 145 {
    abort("fixed_median_145: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 145)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_146(values : Array[Double]) -> Double {
  if values.length() < 146 {
    abort("fixed_median_146: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 146)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_147(values : Array[Double]) -> Double {
  if values.length() < 147 {
    abort("fixed_median_147: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 147)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_148(values : Array[Double]) -> Double {
  if values.length() < 148 {
    abort("fixed_median_148: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 148)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_149(values : Array[Double]) -> Double {
  if values.length() < 149 {
    abort("fixed_median_149: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 149)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_150(values : Array[Double]) -> Double {
  if values.length() < 150 {
    abort("fixed_median_150: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 150)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_151(values : Array[Double]) -> Double {
  if values.length() < 151 {
    abort("fixed_median_151: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 151)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_152(values : Array[Double]) -> Double {
  if values.length() < 152 {
    abort("fixed_median_152: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 152)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_153(values : Array[Double]) -> Double {
  if values.length() < 153 {
    abort("fixed_median_153: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 153)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_154(values : Array[Double]) -> Double {
  if values.length() < 154 {
    abort("fixed_median_154: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 154)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_155(values : Array[Double]) -> Double {
  if values.length() < 155 {
    abort("fixed_median_155: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 155)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_156(values : Array[Double]) -> Double {
  if values.length() < 156 {
    abort("fixed_median_156: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 156)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_157(values : Array[Double]) -> Double {
  if values.length() < 157 {
    abort("fixed_median_157: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 157)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_158(values : Array[Double]) -> Double {
  if values.length() < 158 {
    abort("fixed_median_158: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 158)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_159(values : Array[Double]) -> Double {
  if values.length() < 159 {
    abort("fixed_median_159: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 159)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_median_160(values : Array[Double]) -> Double {
  if values.length() < 160 {
    abort("fixed_median_160: insufficient values")
  }
  let sample : Array[Double] = []
  for index in (values.length() - 160)..<values.length() {
    sample.push(values[index])
  }
  empirical_quantile(sample, 0.5)
}

///|
pub fn fixed_absolute_deviation_001(values : Array[Double]) -> Double {
  if values.length() < 1 {
    abort("fixed_absolute_deviation_001: insufficient values")
  }
  let center = fixed_median_001(values)
  let mut total = 0.0
  for index in (values.length() - 1)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 1.0
}

///|
pub fn fixed_absolute_deviation_002(values : Array[Double]) -> Double {
  if values.length() < 2 {
    abort("fixed_absolute_deviation_002: insufficient values")
  }
  let center = fixed_median_002(values)
  let mut total = 0.0
  for index in (values.length() - 2)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 2.0
}

///|
pub fn fixed_absolute_deviation_003(values : Array[Double]) -> Double {
  if values.length() < 3 {
    abort("fixed_absolute_deviation_003: insufficient values")
  }
  let center = fixed_median_003(values)
  let mut total = 0.0
  for index in (values.length() - 3)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 3.0
}

///|
pub fn fixed_absolute_deviation_004(values : Array[Double]) -> Double {
  if values.length() < 4 {
    abort("fixed_absolute_deviation_004: insufficient values")
  }
  let center = fixed_median_004(values)
  let mut total = 0.0
  for index in (values.length() - 4)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 4.0
}

///|
pub fn fixed_absolute_deviation_005(values : Array[Double]) -> Double {
  if values.length() < 5 {
    abort("fixed_absolute_deviation_005: insufficient values")
  }
  let center = fixed_median_005(values)
  let mut total = 0.0
  for index in (values.length() - 5)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 5.0
}

///|
pub fn fixed_absolute_deviation_006(values : Array[Double]) -> Double {
  if values.length() < 6 {
    abort("fixed_absolute_deviation_006: insufficient values")
  }
  let center = fixed_median_006(values)
  let mut total = 0.0
  for index in (values.length() - 6)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 6.0
}

///|
pub fn fixed_absolute_deviation_007(values : Array[Double]) -> Double {
  if values.length() < 7 {
    abort("fixed_absolute_deviation_007: insufficient values")
  }
  let center = fixed_median_007(values)
  let mut total = 0.0
  for index in (values.length() - 7)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 7.0
}

///|
pub fn fixed_absolute_deviation_008(values : Array[Double]) -> Double {
  if values.length() < 8 {
    abort("fixed_absolute_deviation_008: insufficient values")
  }
  let center = fixed_median_008(values)
  let mut total = 0.0
  for index in (values.length() - 8)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 8.0
}

///|
pub fn fixed_absolute_deviation_009(values : Array[Double]) -> Double {
  if values.length() < 9 {
    abort("fixed_absolute_deviation_009: insufficient values")
  }
  let center = fixed_median_009(values)
  let mut total = 0.0
  for index in (values.length() - 9)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 9.0
}

///|
pub fn fixed_absolute_deviation_010(values : Array[Double]) -> Double {
  if values.length() < 10 {
    abort("fixed_absolute_deviation_010: insufficient values")
  }
  let center = fixed_median_010(values)
  let mut total = 0.0
  for index in (values.length() - 10)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 10.0
}

///|
pub fn fixed_absolute_deviation_011(values : Array[Double]) -> Double {
  if values.length() < 11 {
    abort("fixed_absolute_deviation_011: insufficient values")
  }
  let center = fixed_median_011(values)
  let mut total = 0.0
  for index in (values.length() - 11)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 11.0
}

///|
pub fn fixed_absolute_deviation_012(values : Array[Double]) -> Double {
  if values.length() < 12 {
    abort("fixed_absolute_deviation_012: insufficient values")
  }
  let center = fixed_median_012(values)
  let mut total = 0.0
  for index in (values.length() - 12)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 12.0
}

///|
pub fn fixed_absolute_deviation_013(values : Array[Double]) -> Double {
  if values.length() < 13 {
    abort("fixed_absolute_deviation_013: insufficient values")
  }
  let center = fixed_median_013(values)
  let mut total = 0.0
  for index in (values.length() - 13)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 13.0
}

///|
pub fn fixed_absolute_deviation_014(values : Array[Double]) -> Double {
  if values.length() < 14 {
    abort("fixed_absolute_deviation_014: insufficient values")
  }
  let center = fixed_median_014(values)
  let mut total = 0.0
  for index in (values.length() - 14)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 14.0
}

///|
pub fn fixed_absolute_deviation_015(values : Array[Double]) -> Double {
  if values.length() < 15 {
    abort("fixed_absolute_deviation_015: insufficient values")
  }
  let center = fixed_median_015(values)
  let mut total = 0.0
  for index in (values.length() - 15)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 15.0
}

///|
pub fn fixed_absolute_deviation_016(values : Array[Double]) -> Double {
  if values.length() < 16 {
    abort("fixed_absolute_deviation_016: insufficient values")
  }
  let center = fixed_median_016(values)
  let mut total = 0.0
  for index in (values.length() - 16)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 16.0
}

///|
pub fn fixed_absolute_deviation_017(values : Array[Double]) -> Double {
  if values.length() < 17 {
    abort("fixed_absolute_deviation_017: insufficient values")
  }
  let center = fixed_median_017(values)
  let mut total = 0.0
  for index in (values.length() - 17)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 17.0
}

///|
pub fn fixed_absolute_deviation_018(values : Array[Double]) -> Double {
  if values.length() < 18 {
    abort("fixed_absolute_deviation_018: insufficient values")
  }
  let center = fixed_median_018(values)
  let mut total = 0.0
  for index in (values.length() - 18)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 18.0
}

///|
pub fn fixed_absolute_deviation_019(values : Array[Double]) -> Double {
  if values.length() < 19 {
    abort("fixed_absolute_deviation_019: insufficient values")
  }
  let center = fixed_median_019(values)
  let mut total = 0.0
  for index in (values.length() - 19)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 19.0
}

///|
pub fn fixed_absolute_deviation_020(values : Array[Double]) -> Double {
  if values.length() < 20 {
    abort("fixed_absolute_deviation_020: insufficient values")
  }
  let center = fixed_median_020(values)
  let mut total = 0.0
  for index in (values.length() - 20)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 20.0
}

///|
pub fn fixed_absolute_deviation_021(values : Array[Double]) -> Double {
  if values.length() < 21 {
    abort("fixed_absolute_deviation_021: insufficient values")
  }
  let center = fixed_median_021(values)
  let mut total = 0.0
  for index in (values.length() - 21)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 21.0
}

///|
pub fn fixed_absolute_deviation_022(values : Array[Double]) -> Double {
  if values.length() < 22 {
    abort("fixed_absolute_deviation_022: insufficient values")
  }
  let center = fixed_median_022(values)
  let mut total = 0.0
  for index in (values.length() - 22)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 22.0
}

///|
pub fn fixed_absolute_deviation_023(values : Array[Double]) -> Double {
  if values.length() < 23 {
    abort("fixed_absolute_deviation_023: insufficient values")
  }
  let center = fixed_median_023(values)
  let mut total = 0.0
  for index in (values.length() - 23)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 23.0
}

///|
pub fn fixed_absolute_deviation_024(values : Array[Double]) -> Double {
  if values.length() < 24 {
    abort("fixed_absolute_deviation_024: insufficient values")
  }
  let center = fixed_median_024(values)
  let mut total = 0.0
  for index in (values.length() - 24)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 24.0
}

///|
pub fn fixed_absolute_deviation_025(values : Array[Double]) -> Double {
  if values.length() < 25 {
    abort("fixed_absolute_deviation_025: insufficient values")
  }
  let center = fixed_median_025(values)
  let mut total = 0.0
  for index in (values.length() - 25)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 25.0
}

///|
pub fn fixed_absolute_deviation_026(values : Array[Double]) -> Double {
  if values.length() < 26 {
    abort("fixed_absolute_deviation_026: insufficient values")
  }
  let center = fixed_median_026(values)
  let mut total = 0.0
  for index in (values.length() - 26)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 26.0
}

///|
pub fn fixed_absolute_deviation_027(values : Array[Double]) -> Double {
  if values.length() < 27 {
    abort("fixed_absolute_deviation_027: insufficient values")
  }
  let center = fixed_median_027(values)
  let mut total = 0.0
  for index in (values.length() - 27)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 27.0
}

///|
pub fn fixed_absolute_deviation_028(values : Array[Double]) -> Double {
  if values.length() < 28 {
    abort("fixed_absolute_deviation_028: insufficient values")
  }
  let center = fixed_median_028(values)
  let mut total = 0.0
  for index in (values.length() - 28)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 28.0
}

///|
pub fn fixed_absolute_deviation_029(values : Array[Double]) -> Double {
  if values.length() < 29 {
    abort("fixed_absolute_deviation_029: insufficient values")
  }
  let center = fixed_median_029(values)
  let mut total = 0.0
  for index in (values.length() - 29)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 29.0
}

///|
pub fn fixed_absolute_deviation_030(values : Array[Double]) -> Double {
  if values.length() < 30 {
    abort("fixed_absolute_deviation_030: insufficient values")
  }
  let center = fixed_median_030(values)
  let mut total = 0.0
  for index in (values.length() - 30)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 30.0
}

///|
pub fn fixed_absolute_deviation_031(values : Array[Double]) -> Double {
  if values.length() < 31 {
    abort("fixed_absolute_deviation_031: insufficient values")
  }
  let center = fixed_median_031(values)
  let mut total = 0.0
  for index in (values.length() - 31)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 31.0
}

///|
pub fn fixed_absolute_deviation_032(values : Array[Double]) -> Double {
  if values.length() < 32 {
    abort("fixed_absolute_deviation_032: insufficient values")
  }
  let center = fixed_median_032(values)
  let mut total = 0.0
  for index in (values.length() - 32)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 32.0
}

///|
pub fn fixed_absolute_deviation_033(values : Array[Double]) -> Double {
  if values.length() < 33 {
    abort("fixed_absolute_deviation_033: insufficient values")
  }
  let center = fixed_median_033(values)
  let mut total = 0.0
  for index in (values.length() - 33)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 33.0
}

///|
pub fn fixed_absolute_deviation_034(values : Array[Double]) -> Double {
  if values.length() < 34 {
    abort("fixed_absolute_deviation_034: insufficient values")
  }
  let center = fixed_median_034(values)
  let mut total = 0.0
  for index in (values.length() - 34)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 34.0
}

///|
pub fn fixed_absolute_deviation_035(values : Array[Double]) -> Double {
  if values.length() < 35 {
    abort("fixed_absolute_deviation_035: insufficient values")
  }
  let center = fixed_median_035(values)
  let mut total = 0.0
  for index in (values.length() - 35)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 35.0
}

///|
pub fn fixed_absolute_deviation_036(values : Array[Double]) -> Double {
  if values.length() < 36 {
    abort("fixed_absolute_deviation_036: insufficient values")
  }
  let center = fixed_median_036(values)
  let mut total = 0.0
  for index in (values.length() - 36)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 36.0
}

///|
pub fn fixed_absolute_deviation_037(values : Array[Double]) -> Double {
  if values.length() < 37 {
    abort("fixed_absolute_deviation_037: insufficient values")
  }
  let center = fixed_median_037(values)
  let mut total = 0.0
  for index in (values.length() - 37)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 37.0
}

///|
pub fn fixed_absolute_deviation_038(values : Array[Double]) -> Double {
  if values.length() < 38 {
    abort("fixed_absolute_deviation_038: insufficient values")
  }
  let center = fixed_median_038(values)
  let mut total = 0.0
  for index in (values.length() - 38)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 38.0
}

///|
pub fn fixed_absolute_deviation_039(values : Array[Double]) -> Double {
  if values.length() < 39 {
    abort("fixed_absolute_deviation_039: insufficient values")
  }
  let center = fixed_median_039(values)
  let mut total = 0.0
  for index in (values.length() - 39)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 39.0
}

///|
pub fn fixed_absolute_deviation_040(values : Array[Double]) -> Double {
  if values.length() < 40 {
    abort("fixed_absolute_deviation_040: insufficient values")
  }
  let center = fixed_median_040(values)
  let mut total = 0.0
  for index in (values.length() - 40)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 40.0
}

///|
pub fn fixed_absolute_deviation_041(values : Array[Double]) -> Double {
  if values.length() < 41 {
    abort("fixed_absolute_deviation_041: insufficient values")
  }
  let center = fixed_median_041(values)
  let mut total = 0.0
  for index in (values.length() - 41)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 41.0
}

///|
pub fn fixed_absolute_deviation_042(values : Array[Double]) -> Double {
  if values.length() < 42 {
    abort("fixed_absolute_deviation_042: insufficient values")
  }
  let center = fixed_median_042(values)
  let mut total = 0.0
  for index in (values.length() - 42)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 42.0
}

///|
pub fn fixed_absolute_deviation_043(values : Array[Double]) -> Double {
  if values.length() < 43 {
    abort("fixed_absolute_deviation_043: insufficient values")
  }
  let center = fixed_median_043(values)
  let mut total = 0.0
  for index in (values.length() - 43)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 43.0
}

///|
pub fn fixed_absolute_deviation_044(values : Array[Double]) -> Double {
  if values.length() < 44 {
    abort("fixed_absolute_deviation_044: insufficient values")
  }
  let center = fixed_median_044(values)
  let mut total = 0.0
  for index in (values.length() - 44)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 44.0
}

///|
pub fn fixed_absolute_deviation_045(values : Array[Double]) -> Double {
  if values.length() < 45 {
    abort("fixed_absolute_deviation_045: insufficient values")
  }
  let center = fixed_median_045(values)
  let mut total = 0.0
  for index in (values.length() - 45)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 45.0
}

///|
pub fn fixed_absolute_deviation_046(values : Array[Double]) -> Double {
  if values.length() < 46 {
    abort("fixed_absolute_deviation_046: insufficient values")
  }
  let center = fixed_median_046(values)
  let mut total = 0.0
  for index in (values.length() - 46)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 46.0
}

///|
pub fn fixed_absolute_deviation_047(values : Array[Double]) -> Double {
  if values.length() < 47 {
    abort("fixed_absolute_deviation_047: insufficient values")
  }
  let center = fixed_median_047(values)
  let mut total = 0.0
  for index in (values.length() - 47)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 47.0
}

///|
pub fn fixed_absolute_deviation_048(values : Array[Double]) -> Double {
  if values.length() < 48 {
    abort("fixed_absolute_deviation_048: insufficient values")
  }
  let center = fixed_median_048(values)
  let mut total = 0.0
  for index in (values.length() - 48)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 48.0
}

///|
pub fn fixed_absolute_deviation_049(values : Array[Double]) -> Double {
  if values.length() < 49 {
    abort("fixed_absolute_deviation_049: insufficient values")
  }
  let center = fixed_median_049(values)
  let mut total = 0.0
  for index in (values.length() - 49)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 49.0
}

///|
pub fn fixed_absolute_deviation_050(values : Array[Double]) -> Double {
  if values.length() < 50 {
    abort("fixed_absolute_deviation_050: insufficient values")
  }
  let center = fixed_median_050(values)
  let mut total = 0.0
  for index in (values.length() - 50)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 50.0
}

///|
pub fn fixed_absolute_deviation_051(values : Array[Double]) -> Double {
  if values.length() < 51 {
    abort("fixed_absolute_deviation_051: insufficient values")
  }
  let center = fixed_median_051(values)
  let mut total = 0.0
  for index in (values.length() - 51)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 51.0
}

///|
pub fn fixed_absolute_deviation_052(values : Array[Double]) -> Double {
  if values.length() < 52 {
    abort("fixed_absolute_deviation_052: insufficient values")
  }
  let center = fixed_median_052(values)
  let mut total = 0.0
  for index in (values.length() - 52)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 52.0
}

///|
pub fn fixed_absolute_deviation_053(values : Array[Double]) -> Double {
  if values.length() < 53 {
    abort("fixed_absolute_deviation_053: insufficient values")
  }
  let center = fixed_median_053(values)
  let mut total = 0.0
  for index in (values.length() - 53)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 53.0
}

///|
pub fn fixed_absolute_deviation_054(values : Array[Double]) -> Double {
  if values.length() < 54 {
    abort("fixed_absolute_deviation_054: insufficient values")
  }
  let center = fixed_median_054(values)
  let mut total = 0.0
  for index in (values.length() - 54)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 54.0
}

///|
pub fn fixed_absolute_deviation_055(values : Array[Double]) -> Double {
  if values.length() < 55 {
    abort("fixed_absolute_deviation_055: insufficient values")
  }
  let center = fixed_median_055(values)
  let mut total = 0.0
  for index in (values.length() - 55)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 55.0
}

///|
pub fn fixed_absolute_deviation_056(values : Array[Double]) -> Double {
  if values.length() < 56 {
    abort("fixed_absolute_deviation_056: insufficient values")
  }
  let center = fixed_median_056(values)
  let mut total = 0.0
  for index in (values.length() - 56)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 56.0
}

///|
pub fn fixed_absolute_deviation_057(values : Array[Double]) -> Double {
  if values.length() < 57 {
    abort("fixed_absolute_deviation_057: insufficient values")
  }
  let center = fixed_median_057(values)
  let mut total = 0.0
  for index in (values.length() - 57)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 57.0
}

///|
pub fn fixed_absolute_deviation_058(values : Array[Double]) -> Double {
  if values.length() < 58 {
    abort("fixed_absolute_deviation_058: insufficient values")
  }
  let center = fixed_median_058(values)
  let mut total = 0.0
  for index in (values.length() - 58)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 58.0
}

///|
pub fn fixed_absolute_deviation_059(values : Array[Double]) -> Double {
  if values.length() < 59 {
    abort("fixed_absolute_deviation_059: insufficient values")
  }
  let center = fixed_median_059(values)
  let mut total = 0.0
  for index in (values.length() - 59)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 59.0
}

///|
pub fn fixed_absolute_deviation_060(values : Array[Double]) -> Double {
  if values.length() < 60 {
    abort("fixed_absolute_deviation_060: insufficient values")
  }
  let center = fixed_median_060(values)
  let mut total = 0.0
  for index in (values.length() - 60)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 60.0
}

///|
pub fn fixed_absolute_deviation_061(values : Array[Double]) -> Double {
  if values.length() < 61 {
    abort("fixed_absolute_deviation_061: insufficient values")
  }
  let center = fixed_median_061(values)
  let mut total = 0.0
  for index in (values.length() - 61)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 61.0
}

///|
pub fn fixed_absolute_deviation_062(values : Array[Double]) -> Double {
  if values.length() < 62 {
    abort("fixed_absolute_deviation_062: insufficient values")
  }
  let center = fixed_median_062(values)
  let mut total = 0.0
  for index in (values.length() - 62)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 62.0
}

///|
pub fn fixed_absolute_deviation_063(values : Array[Double]) -> Double {
  if values.length() < 63 {
    abort("fixed_absolute_deviation_063: insufficient values")
  }
  let center = fixed_median_063(values)
  let mut total = 0.0
  for index in (values.length() - 63)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 63.0
}

///|
pub fn fixed_absolute_deviation_064(values : Array[Double]) -> Double {
  if values.length() < 64 {
    abort("fixed_absolute_deviation_064: insufficient values")
  }
  let center = fixed_median_064(values)
  let mut total = 0.0
  for index in (values.length() - 64)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 64.0
}

///|
pub fn fixed_absolute_deviation_065(values : Array[Double]) -> Double {
  if values.length() < 65 {
    abort("fixed_absolute_deviation_065: insufficient values")
  }
  let center = fixed_median_065(values)
  let mut total = 0.0
  for index in (values.length() - 65)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 65.0
}

///|
pub fn fixed_absolute_deviation_066(values : Array[Double]) -> Double {
  if values.length() < 66 {
    abort("fixed_absolute_deviation_066: insufficient values")
  }
  let center = fixed_median_066(values)
  let mut total = 0.0
  for index in (values.length() - 66)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 66.0
}

///|
pub fn fixed_absolute_deviation_067(values : Array[Double]) -> Double {
  if values.length() < 67 {
    abort("fixed_absolute_deviation_067: insufficient values")
  }
  let center = fixed_median_067(values)
  let mut total = 0.0
  for index in (values.length() - 67)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 67.0
}

///|
pub fn fixed_absolute_deviation_068(values : Array[Double]) -> Double {
  if values.length() < 68 {
    abort("fixed_absolute_deviation_068: insufficient values")
  }
  let center = fixed_median_068(values)
  let mut total = 0.0
  for index in (values.length() - 68)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 68.0
}

///|
pub fn fixed_absolute_deviation_069(values : Array[Double]) -> Double {
  if values.length() < 69 {
    abort("fixed_absolute_deviation_069: insufficient values")
  }
  let center = fixed_median_069(values)
  let mut total = 0.0
  for index in (values.length() - 69)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 69.0
}

///|
pub fn fixed_absolute_deviation_070(values : Array[Double]) -> Double {
  if values.length() < 70 {
    abort("fixed_absolute_deviation_070: insufficient values")
  }
  let center = fixed_median_070(values)
  let mut total = 0.0
  for index in (values.length() - 70)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 70.0
}

///|
pub fn fixed_absolute_deviation_071(values : Array[Double]) -> Double {
  if values.length() < 71 {
    abort("fixed_absolute_deviation_071: insufficient values")
  }
  let center = fixed_median_071(values)
  let mut total = 0.0
  for index in (values.length() - 71)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 71.0
}

///|
pub fn fixed_absolute_deviation_072(values : Array[Double]) -> Double {
  if values.length() < 72 {
    abort("fixed_absolute_deviation_072: insufficient values")
  }
  let center = fixed_median_072(values)
  let mut total = 0.0
  for index in (values.length() - 72)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 72.0
}

///|
pub fn fixed_absolute_deviation_073(values : Array[Double]) -> Double {
  if values.length() < 73 {
    abort("fixed_absolute_deviation_073: insufficient values")
  }
  let center = fixed_median_073(values)
  let mut total = 0.0
  for index in (values.length() - 73)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 73.0
}

///|
pub fn fixed_absolute_deviation_074(values : Array[Double]) -> Double {
  if values.length() < 74 {
    abort("fixed_absolute_deviation_074: insufficient values")
  }
  let center = fixed_median_074(values)
  let mut total = 0.0
  for index in (values.length() - 74)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 74.0
}

///|
pub fn fixed_absolute_deviation_075(values : Array[Double]) -> Double {
  if values.length() < 75 {
    abort("fixed_absolute_deviation_075: insufficient values")
  }
  let center = fixed_median_075(values)
  let mut total = 0.0
  for index in (values.length() - 75)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 75.0
}

///|
pub fn fixed_absolute_deviation_076(values : Array[Double]) -> Double {
  if values.length() < 76 {
    abort("fixed_absolute_deviation_076: insufficient values")
  }
  let center = fixed_median_076(values)
  let mut total = 0.0
  for index in (values.length() - 76)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 76.0
}

///|
pub fn fixed_absolute_deviation_077(values : Array[Double]) -> Double {
  if values.length() < 77 {
    abort("fixed_absolute_deviation_077: insufficient values")
  }
  let center = fixed_median_077(values)
  let mut total = 0.0
  for index in (values.length() - 77)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 77.0
}

///|
pub fn fixed_absolute_deviation_078(values : Array[Double]) -> Double {
  if values.length() < 78 {
    abort("fixed_absolute_deviation_078: insufficient values")
  }
  let center = fixed_median_078(values)
  let mut total = 0.0
  for index in (values.length() - 78)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 78.0
}

///|
pub fn fixed_absolute_deviation_079(values : Array[Double]) -> Double {
  if values.length() < 79 {
    abort("fixed_absolute_deviation_079: insufficient values")
  }
  let center = fixed_median_079(values)
  let mut total = 0.0
  for index in (values.length() - 79)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 79.0
}

///|
pub fn fixed_absolute_deviation_080(values : Array[Double]) -> Double {
  if values.length() < 80 {
    abort("fixed_absolute_deviation_080: insufficient values")
  }
  let center = fixed_median_080(values)
  let mut total = 0.0
  for index in (values.length() - 80)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 80.0
}

///|
pub fn fixed_absolute_deviation_081(values : Array[Double]) -> Double {
  if values.length() < 81 {
    abort("fixed_absolute_deviation_081: insufficient values")
  }
  let center = fixed_median_081(values)
  let mut total = 0.0
  for index in (values.length() - 81)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 81.0
}

///|
pub fn fixed_absolute_deviation_082(values : Array[Double]) -> Double {
  if values.length() < 82 {
    abort("fixed_absolute_deviation_082: insufficient values")
  }
  let center = fixed_median_082(values)
  let mut total = 0.0
  for index in (values.length() - 82)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 82.0
}

///|
pub fn fixed_absolute_deviation_083(values : Array[Double]) -> Double {
  if values.length() < 83 {
    abort("fixed_absolute_deviation_083: insufficient values")
  }
  let center = fixed_median_083(values)
  let mut total = 0.0
  for index in (values.length() - 83)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 83.0
}

///|
pub fn fixed_absolute_deviation_084(values : Array[Double]) -> Double {
  if values.length() < 84 {
    abort("fixed_absolute_deviation_084: insufficient values")
  }
  let center = fixed_median_084(values)
  let mut total = 0.0
  for index in (values.length() - 84)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 84.0
}

///|
pub fn fixed_absolute_deviation_085(values : Array[Double]) -> Double {
  if values.length() < 85 {
    abort("fixed_absolute_deviation_085: insufficient values")
  }
  let center = fixed_median_085(values)
  let mut total = 0.0
  for index in (values.length() - 85)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 85.0
}

///|
pub fn fixed_absolute_deviation_086(values : Array[Double]) -> Double {
  if values.length() < 86 {
    abort("fixed_absolute_deviation_086: insufficient values")
  }
  let center = fixed_median_086(values)
  let mut total = 0.0
  for index in (values.length() - 86)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 86.0
}

///|
pub fn fixed_absolute_deviation_087(values : Array[Double]) -> Double {
  if values.length() < 87 {
    abort("fixed_absolute_deviation_087: insufficient values")
  }
  let center = fixed_median_087(values)
  let mut total = 0.0
  for index in (values.length() - 87)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 87.0
}

///|
pub fn fixed_absolute_deviation_088(values : Array[Double]) -> Double {
  if values.length() < 88 {
    abort("fixed_absolute_deviation_088: insufficient values")
  }
  let center = fixed_median_088(values)
  let mut total = 0.0
  for index in (values.length() - 88)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 88.0
}

///|
pub fn fixed_absolute_deviation_089(values : Array[Double]) -> Double {
  if values.length() < 89 {
    abort("fixed_absolute_deviation_089: insufficient values")
  }
  let center = fixed_median_089(values)
  let mut total = 0.0
  for index in (values.length() - 89)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 89.0
}

///|
pub fn fixed_absolute_deviation_090(values : Array[Double]) -> Double {
  if values.length() < 90 {
    abort("fixed_absolute_deviation_090: insufficient values")
  }
  let center = fixed_median_090(values)
  let mut total = 0.0
  for index in (values.length() - 90)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 90.0
}

///|
pub fn fixed_absolute_deviation_091(values : Array[Double]) -> Double {
  if values.length() < 91 {
    abort("fixed_absolute_deviation_091: insufficient values")
  }
  let center = fixed_median_091(values)
  let mut total = 0.0
  for index in (values.length() - 91)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 91.0
}

///|
pub fn fixed_absolute_deviation_092(values : Array[Double]) -> Double {
  if values.length() < 92 {
    abort("fixed_absolute_deviation_092: insufficient values")
  }
  let center = fixed_median_092(values)
  let mut total = 0.0
  for index in (values.length() - 92)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 92.0
}

///|
pub fn fixed_absolute_deviation_093(values : Array[Double]) -> Double {
  if values.length() < 93 {
    abort("fixed_absolute_deviation_093: insufficient values")
  }
  let center = fixed_median_093(values)
  let mut total = 0.0
  for index in (values.length() - 93)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 93.0
}

///|
pub fn fixed_absolute_deviation_094(values : Array[Double]) -> Double {
  if values.length() < 94 {
    abort("fixed_absolute_deviation_094: insufficient values")
  }
  let center = fixed_median_094(values)
  let mut total = 0.0
  for index in (values.length() - 94)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 94.0
}

///|
pub fn fixed_absolute_deviation_095(values : Array[Double]) -> Double {
  if values.length() < 95 {
    abort("fixed_absolute_deviation_095: insufficient values")
  }
  let center = fixed_median_095(values)
  let mut total = 0.0
  for index in (values.length() - 95)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 95.0
}

///|
pub fn fixed_absolute_deviation_096(values : Array[Double]) -> Double {
  if values.length() < 96 {
    abort("fixed_absolute_deviation_096: insufficient values")
  }
  let center = fixed_median_096(values)
  let mut total = 0.0
  for index in (values.length() - 96)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 96.0
}

///|
pub fn fixed_absolute_deviation_097(values : Array[Double]) -> Double {
  if values.length() < 97 {
    abort("fixed_absolute_deviation_097: insufficient values")
  }
  let center = fixed_median_097(values)
  let mut total = 0.0
  for index in (values.length() - 97)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 97.0
}

///|
pub fn fixed_absolute_deviation_098(values : Array[Double]) -> Double {
  if values.length() < 98 {
    abort("fixed_absolute_deviation_098: insufficient values")
  }
  let center = fixed_median_098(values)
  let mut total = 0.0
  for index in (values.length() - 98)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 98.0
}

///|
pub fn fixed_absolute_deviation_099(values : Array[Double]) -> Double {
  if values.length() < 99 {
    abort("fixed_absolute_deviation_099: insufficient values")
  }
  let center = fixed_median_099(values)
  let mut total = 0.0
  for index in (values.length() - 99)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 99.0
}

///|
pub fn fixed_absolute_deviation_100(values : Array[Double]) -> Double {
  if values.length() < 100 {
    abort("fixed_absolute_deviation_100: insufficient values")
  }
  let center = fixed_median_100(values)
  let mut total = 0.0
  for index in (values.length() - 100)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 100.0
}

///|
pub fn fixed_absolute_deviation_101(values : Array[Double]) -> Double {
  if values.length() < 101 {
    abort("fixed_absolute_deviation_101: insufficient values")
  }
  let center = fixed_median_101(values)
  let mut total = 0.0
  for index in (values.length() - 101)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 101.0
}

///|
pub fn fixed_absolute_deviation_102(values : Array[Double]) -> Double {
  if values.length() < 102 {
    abort("fixed_absolute_deviation_102: insufficient values")
  }
  let center = fixed_median_102(values)
  let mut total = 0.0
  for index in (values.length() - 102)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 102.0
}

///|
pub fn fixed_absolute_deviation_103(values : Array[Double]) -> Double {
  if values.length() < 103 {
    abort("fixed_absolute_deviation_103: insufficient values")
  }
  let center = fixed_median_103(values)
  let mut total = 0.0
  for index in (values.length() - 103)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 103.0
}

///|
pub fn fixed_absolute_deviation_104(values : Array[Double]) -> Double {
  if values.length() < 104 {
    abort("fixed_absolute_deviation_104: insufficient values")
  }
  let center = fixed_median_104(values)
  let mut total = 0.0
  for index in (values.length() - 104)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 104.0
}

///|
pub fn fixed_absolute_deviation_105(values : Array[Double]) -> Double {
  if values.length() < 105 {
    abort("fixed_absolute_deviation_105: insufficient values")
  }
  let center = fixed_median_105(values)
  let mut total = 0.0
  for index in (values.length() - 105)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 105.0
}

///|
pub fn fixed_absolute_deviation_106(values : Array[Double]) -> Double {
  if values.length() < 106 {
    abort("fixed_absolute_deviation_106: insufficient values")
  }
  let center = fixed_median_106(values)
  let mut total = 0.0
  for index in (values.length() - 106)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 106.0
}

///|
pub fn fixed_absolute_deviation_107(values : Array[Double]) -> Double {
  if values.length() < 107 {
    abort("fixed_absolute_deviation_107: insufficient values")
  }
  let center = fixed_median_107(values)
  let mut total = 0.0
  for index in (values.length() - 107)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 107.0
}

///|
pub fn fixed_absolute_deviation_108(values : Array[Double]) -> Double {
  if values.length() < 108 {
    abort("fixed_absolute_deviation_108: insufficient values")
  }
  let center = fixed_median_108(values)
  let mut total = 0.0
  for index in (values.length() - 108)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 108.0
}

///|
pub fn fixed_absolute_deviation_109(values : Array[Double]) -> Double {
  if values.length() < 109 {
    abort("fixed_absolute_deviation_109: insufficient values")
  }
  let center = fixed_median_109(values)
  let mut total = 0.0
  for index in (values.length() - 109)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 109.0
}

///|
pub fn fixed_absolute_deviation_110(values : Array[Double]) -> Double {
  if values.length() < 110 {
    abort("fixed_absolute_deviation_110: insufficient values")
  }
  let center = fixed_median_110(values)
  let mut total = 0.0
  for index in (values.length() - 110)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 110.0
}

///|
pub fn fixed_absolute_deviation_111(values : Array[Double]) -> Double {
  if values.length() < 111 {
    abort("fixed_absolute_deviation_111: insufficient values")
  }
  let center = fixed_median_111(values)
  let mut total = 0.0
  for index in (values.length() - 111)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 111.0
}

///|
pub fn fixed_absolute_deviation_112(values : Array[Double]) -> Double {
  if values.length() < 112 {
    abort("fixed_absolute_deviation_112: insufficient values")
  }
  let center = fixed_median_112(values)
  let mut total = 0.0
  for index in (values.length() - 112)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 112.0
}

///|
pub fn fixed_absolute_deviation_113(values : Array[Double]) -> Double {
  if values.length() < 113 {
    abort("fixed_absolute_deviation_113: insufficient values")
  }
  let center = fixed_median_113(values)
  let mut total = 0.0
  for index in (values.length() - 113)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 113.0
}

///|
pub fn fixed_absolute_deviation_114(values : Array[Double]) -> Double {
  if values.length() < 114 {
    abort("fixed_absolute_deviation_114: insufficient values")
  }
  let center = fixed_median_114(values)
  let mut total = 0.0
  for index in (values.length() - 114)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 114.0
}

///|
pub fn fixed_absolute_deviation_115(values : Array[Double]) -> Double {
  if values.length() < 115 {
    abort("fixed_absolute_deviation_115: insufficient values")
  }
  let center = fixed_median_115(values)
  let mut total = 0.0
  for index in (values.length() - 115)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 115.0
}

///|
pub fn fixed_absolute_deviation_116(values : Array[Double]) -> Double {
  if values.length() < 116 {
    abort("fixed_absolute_deviation_116: insufficient values")
  }
  let center = fixed_median_116(values)
  let mut total = 0.0
  for index in (values.length() - 116)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 116.0
}

///|
pub fn fixed_absolute_deviation_117(values : Array[Double]) -> Double {
  if values.length() < 117 {
    abort("fixed_absolute_deviation_117: insufficient values")
  }
  let center = fixed_median_117(values)
  let mut total = 0.0
  for index in (values.length() - 117)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 117.0
}

///|
pub fn fixed_absolute_deviation_118(values : Array[Double]) -> Double {
  if values.length() < 118 {
    abort("fixed_absolute_deviation_118: insufficient values")
  }
  let center = fixed_median_118(values)
  let mut total = 0.0
  for index in (values.length() - 118)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 118.0
}

///|
pub fn fixed_absolute_deviation_119(values : Array[Double]) -> Double {
  if values.length() < 119 {
    abort("fixed_absolute_deviation_119: insufficient values")
  }
  let center = fixed_median_119(values)
  let mut total = 0.0
  for index in (values.length() - 119)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 119.0
}

///|
pub fn fixed_absolute_deviation_120(values : Array[Double]) -> Double {
  if values.length() < 120 {
    abort("fixed_absolute_deviation_120: insufficient values")
  }
  let center = fixed_median_120(values)
  let mut total = 0.0
  for index in (values.length() - 120)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 120.0
}

///|
pub fn fixed_absolute_deviation_121(values : Array[Double]) -> Double {
  if values.length() < 121 {
    abort("fixed_absolute_deviation_121: insufficient values")
  }
  let center = fixed_median_121(values)
  let mut total = 0.0
  for index in (values.length() - 121)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 121.0
}

///|
pub fn fixed_absolute_deviation_122(values : Array[Double]) -> Double {
  if values.length() < 122 {
    abort("fixed_absolute_deviation_122: insufficient values")
  }
  let center = fixed_median_122(values)
  let mut total = 0.0
  for index in (values.length() - 122)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 122.0
}

///|
pub fn fixed_absolute_deviation_123(values : Array[Double]) -> Double {
  if values.length() < 123 {
    abort("fixed_absolute_deviation_123: insufficient values")
  }
  let center = fixed_median_123(values)
  let mut total = 0.0
  for index in (values.length() - 123)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 123.0
}

///|
pub fn fixed_absolute_deviation_124(values : Array[Double]) -> Double {
  if values.length() < 124 {
    abort("fixed_absolute_deviation_124: insufficient values")
  }
  let center = fixed_median_124(values)
  let mut total = 0.0
  for index in (values.length() - 124)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 124.0
}

///|
pub fn fixed_absolute_deviation_125(values : Array[Double]) -> Double {
  if values.length() < 125 {
    abort("fixed_absolute_deviation_125: insufficient values")
  }
  let center = fixed_median_125(values)
  let mut total = 0.0
  for index in (values.length() - 125)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 125.0
}

///|
pub fn fixed_absolute_deviation_126(values : Array[Double]) -> Double {
  if values.length() < 126 {
    abort("fixed_absolute_deviation_126: insufficient values")
  }
  let center = fixed_median_126(values)
  let mut total = 0.0
  for index in (values.length() - 126)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 126.0
}

///|
pub fn fixed_absolute_deviation_127(values : Array[Double]) -> Double {
  if values.length() < 127 {
    abort("fixed_absolute_deviation_127: insufficient values")
  }
  let center = fixed_median_127(values)
  let mut total = 0.0
  for index in (values.length() - 127)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 127.0
}

///|
pub fn fixed_absolute_deviation_128(values : Array[Double]) -> Double {
  if values.length() < 128 {
    abort("fixed_absolute_deviation_128: insufficient values")
  }
  let center = fixed_median_128(values)
  let mut total = 0.0
  for index in (values.length() - 128)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 128.0
}

///|
pub fn fixed_absolute_deviation_129(values : Array[Double]) -> Double {
  if values.length() < 129 {
    abort("fixed_absolute_deviation_129: insufficient values")
  }
  let center = fixed_median_129(values)
  let mut total = 0.0
  for index in (values.length() - 129)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 129.0
}

///|
pub fn fixed_absolute_deviation_130(values : Array[Double]) -> Double {
  if values.length() < 130 {
    abort("fixed_absolute_deviation_130: insufficient values")
  }
  let center = fixed_median_130(values)
  let mut total = 0.0
  for index in (values.length() - 130)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 130.0
}

///|
pub fn fixed_absolute_deviation_131(values : Array[Double]) -> Double {
  if values.length() < 131 {
    abort("fixed_absolute_deviation_131: insufficient values")
  }
  let center = fixed_median_131(values)
  let mut total = 0.0
  for index in (values.length() - 131)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 131.0
}

///|
pub fn fixed_absolute_deviation_132(values : Array[Double]) -> Double {
  if values.length() < 132 {
    abort("fixed_absolute_deviation_132: insufficient values")
  }
  let center = fixed_median_132(values)
  let mut total = 0.0
  for index in (values.length() - 132)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 132.0
}

///|
pub fn fixed_absolute_deviation_133(values : Array[Double]) -> Double {
  if values.length() < 133 {
    abort("fixed_absolute_deviation_133: insufficient values")
  }
  let center = fixed_median_133(values)
  let mut total = 0.0
  for index in (values.length() - 133)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 133.0
}

///|
pub fn fixed_absolute_deviation_134(values : Array[Double]) -> Double {
  if values.length() < 134 {
    abort("fixed_absolute_deviation_134: insufficient values")
  }
  let center = fixed_median_134(values)
  let mut total = 0.0
  for index in (values.length() - 134)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 134.0
}

///|
pub fn fixed_absolute_deviation_135(values : Array[Double]) -> Double {
  if values.length() < 135 {
    abort("fixed_absolute_deviation_135: insufficient values")
  }
  let center = fixed_median_135(values)
  let mut total = 0.0
  for index in (values.length() - 135)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 135.0
}

///|
pub fn fixed_absolute_deviation_136(values : Array[Double]) -> Double {
  if values.length() < 136 {
    abort("fixed_absolute_deviation_136: insufficient values")
  }
  let center = fixed_median_136(values)
  let mut total = 0.0
  for index in (values.length() - 136)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 136.0
}

///|
pub fn fixed_absolute_deviation_137(values : Array[Double]) -> Double {
  if values.length() < 137 {
    abort("fixed_absolute_deviation_137: insufficient values")
  }
  let center = fixed_median_137(values)
  let mut total = 0.0
  for index in (values.length() - 137)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 137.0
}

///|
pub fn fixed_absolute_deviation_138(values : Array[Double]) -> Double {
  if values.length() < 138 {
    abort("fixed_absolute_deviation_138: insufficient values")
  }
  let center = fixed_median_138(values)
  let mut total = 0.0
  for index in (values.length() - 138)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 138.0
}

///|
pub fn fixed_absolute_deviation_139(values : Array[Double]) -> Double {
  if values.length() < 139 {
    abort("fixed_absolute_deviation_139: insufficient values")
  }
  let center = fixed_median_139(values)
  let mut total = 0.0
  for index in (values.length() - 139)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 139.0
}

///|
pub fn fixed_absolute_deviation_140(values : Array[Double]) -> Double {
  if values.length() < 140 {
    abort("fixed_absolute_deviation_140: insufficient values")
  }
  let center = fixed_median_140(values)
  let mut total = 0.0
  for index in (values.length() - 140)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 140.0
}

///|
pub fn fixed_absolute_deviation_141(values : Array[Double]) -> Double {
  if values.length() < 141 {
    abort("fixed_absolute_deviation_141: insufficient values")
  }
  let center = fixed_median_141(values)
  let mut total = 0.0
  for index in (values.length() - 141)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 141.0
}

///|
pub fn fixed_absolute_deviation_142(values : Array[Double]) -> Double {
  if values.length() < 142 {
    abort("fixed_absolute_deviation_142: insufficient values")
  }
  let center = fixed_median_142(values)
  let mut total = 0.0
  for index in (values.length() - 142)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 142.0
}

///|
pub fn fixed_absolute_deviation_143(values : Array[Double]) -> Double {
  if values.length() < 143 {
    abort("fixed_absolute_deviation_143: insufficient values")
  }
  let center = fixed_median_143(values)
  let mut total = 0.0
  for index in (values.length() - 143)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 143.0
}

///|
pub fn fixed_absolute_deviation_144(values : Array[Double]) -> Double {
  if values.length() < 144 {
    abort("fixed_absolute_deviation_144: insufficient values")
  }
  let center = fixed_median_144(values)
  let mut total = 0.0
  for index in (values.length() - 144)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 144.0
}

///|
pub fn fixed_absolute_deviation_145(values : Array[Double]) -> Double {
  if values.length() < 145 {
    abort("fixed_absolute_deviation_145: insufficient values")
  }
  let center = fixed_median_145(values)
  let mut total = 0.0
  for index in (values.length() - 145)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 145.0
}

///|
pub fn fixed_absolute_deviation_146(values : Array[Double]) -> Double {
  if values.length() < 146 {
    abort("fixed_absolute_deviation_146: insufficient values")
  }
  let center = fixed_median_146(values)
  let mut total = 0.0
  for index in (values.length() - 146)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 146.0
}

///|
pub fn fixed_absolute_deviation_147(values : Array[Double]) -> Double {
  if values.length() < 147 {
    abort("fixed_absolute_deviation_147: insufficient values")
  }
  let center = fixed_median_147(values)
  let mut total = 0.0
  for index in (values.length() - 147)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 147.0
}

///|
pub fn fixed_absolute_deviation_148(values : Array[Double]) -> Double {
  if values.length() < 148 {
    abort("fixed_absolute_deviation_148: insufficient values")
  }
  let center = fixed_median_148(values)
  let mut total = 0.0
  for index in (values.length() - 148)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 148.0
}

///|
pub fn fixed_absolute_deviation_149(values : Array[Double]) -> Double {
  if values.length() < 149 {
    abort("fixed_absolute_deviation_149: insufficient values")
  }
  let center = fixed_median_149(values)
  let mut total = 0.0
  for index in (values.length() - 149)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 149.0
}

///|
pub fn fixed_absolute_deviation_150(values : Array[Double]) -> Double {
  if values.length() < 150 {
    abort("fixed_absolute_deviation_150: insufficient values")
  }
  let center = fixed_median_150(values)
  let mut total = 0.0
  for index in (values.length() - 150)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 150.0
}

///|
pub fn fixed_absolute_deviation_151(values : Array[Double]) -> Double {
  if values.length() < 151 {
    abort("fixed_absolute_deviation_151: insufficient values")
  }
  let center = fixed_median_151(values)
  let mut total = 0.0
  for index in (values.length() - 151)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 151.0
}

///|
pub fn fixed_absolute_deviation_152(values : Array[Double]) -> Double {
  if values.length() < 152 {
    abort("fixed_absolute_deviation_152: insufficient values")
  }
  let center = fixed_median_152(values)
  let mut total = 0.0
  for index in (values.length() - 152)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 152.0
}

///|
pub fn fixed_absolute_deviation_153(values : Array[Double]) -> Double {
  if values.length() < 153 {
    abort("fixed_absolute_deviation_153: insufficient values")
  }
  let center = fixed_median_153(values)
  let mut total = 0.0
  for index in (values.length() - 153)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 153.0
}

///|
pub fn fixed_absolute_deviation_154(values : Array[Double]) -> Double {
  if values.length() < 154 {
    abort("fixed_absolute_deviation_154: insufficient values")
  }
  let center = fixed_median_154(values)
  let mut total = 0.0
  for index in (values.length() - 154)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 154.0
}

///|
pub fn fixed_absolute_deviation_155(values : Array[Double]) -> Double {
  if values.length() < 155 {
    abort("fixed_absolute_deviation_155: insufficient values")
  }
  let center = fixed_median_155(values)
  let mut total = 0.0
  for index in (values.length() - 155)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 155.0
}

///|
pub fn fixed_absolute_deviation_156(values : Array[Double]) -> Double {
  if values.length() < 156 {
    abort("fixed_absolute_deviation_156: insufficient values")
  }
  let center = fixed_median_156(values)
  let mut total = 0.0
  for index in (values.length() - 156)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 156.0
}

///|
pub fn fixed_absolute_deviation_157(values : Array[Double]) -> Double {
  if values.length() < 157 {
    abort("fixed_absolute_deviation_157: insufficient values")
  }
  let center = fixed_median_157(values)
  let mut total = 0.0
  for index in (values.length() - 157)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 157.0
}

///|
pub fn fixed_absolute_deviation_158(values : Array[Double]) -> Double {
  if values.length() < 158 {
    abort("fixed_absolute_deviation_158: insufficient values")
  }
  let center = fixed_median_158(values)
  let mut total = 0.0
  for index in (values.length() - 158)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 158.0
}

///|
pub fn fixed_absolute_deviation_159(values : Array[Double]) -> Double {
  if values.length() < 159 {
    abort("fixed_absolute_deviation_159: insufficient values")
  }
  let center = fixed_median_159(values)
  let mut total = 0.0
  for index in (values.length() - 159)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 159.0
}

///|
pub fn fixed_absolute_deviation_160(values : Array[Double]) -> Double {
  if values.length() < 160 {
    abort("fixed_absolute_deviation_160: insufficient values")
  }
  let center = fixed_median_160(values)
  let mut total = 0.0
  for index in (values.length() - 160)..<values.length() {
    total = total + (values[index] - center).abs()
  }
  total / 160.0
}
