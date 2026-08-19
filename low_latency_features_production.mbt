///| Fixed-window kernels for predictable low-latency feature extraction.

///| The explicit window APIs are useful when a serving path cannot allocate a

///|
/// dynamic rolling buffer for every request.
pub fn fixed_mean_001(values : Array[Double]) -> Double {
  if values.length() < 1 {
    abort("fixed_mean_001: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 1)..<values.length() {
    total = total + values[index]
  }
  total / 1.0
}

///|
pub fn fixed_mean_002(values : Array[Double]) -> Double {
  if values.length() < 2 {
    abort("fixed_mean_002: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 2)..<values.length() {
    total = total + values[index]
  }
  total / 2.0
}

///|
pub fn fixed_mean_003(values : Array[Double]) -> Double {
  if values.length() < 3 {
    abort("fixed_mean_003: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 3)..<values.length() {
    total = total + values[index]
  }
  total / 3.0
}

///|
pub fn fixed_mean_004(values : Array[Double]) -> Double {
  if values.length() < 4 {
    abort("fixed_mean_004: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 4)..<values.length() {
    total = total + values[index]
  }
  total / 4.0
}

///|
pub fn fixed_mean_005(values : Array[Double]) -> Double {
  if values.length() < 5 {
    abort("fixed_mean_005: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 5)..<values.length() {
    total = total + values[index]
  }
  total / 5.0
}

///|
pub fn fixed_mean_006(values : Array[Double]) -> Double {
  if values.length() < 6 {
    abort("fixed_mean_006: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 6)..<values.length() {
    total = total + values[index]
  }
  total / 6.0
}

///|
pub fn fixed_mean_007(values : Array[Double]) -> Double {
  if values.length() < 7 {
    abort("fixed_mean_007: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 7)..<values.length() {
    total = total + values[index]
  }
  total / 7.0
}

///|
pub fn fixed_mean_008(values : Array[Double]) -> Double {
  if values.length() < 8 {
    abort("fixed_mean_008: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 8)..<values.length() {
    total = total + values[index]
  }
  total / 8.0
}

///|
pub fn fixed_mean_009(values : Array[Double]) -> Double {
  if values.length() < 9 {
    abort("fixed_mean_009: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 9)..<values.length() {
    total = total + values[index]
  }
  total / 9.0
}

///|
pub fn fixed_mean_010(values : Array[Double]) -> Double {
  if values.length() < 10 {
    abort("fixed_mean_010: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 10)..<values.length() {
    total = total + values[index]
  }
  total / 10.0
}

///|
pub fn fixed_mean_011(values : Array[Double]) -> Double {
  if values.length() < 11 {
    abort("fixed_mean_011: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 11)..<values.length() {
    total = total + values[index]
  }
  total / 11.0
}

///|
pub fn fixed_mean_012(values : Array[Double]) -> Double {
  if values.length() < 12 {
    abort("fixed_mean_012: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 12)..<values.length() {
    total = total + values[index]
  }
  total / 12.0
}

///|
pub fn fixed_mean_013(values : Array[Double]) -> Double {
  if values.length() < 13 {
    abort("fixed_mean_013: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 13)..<values.length() {
    total = total + values[index]
  }
  total / 13.0
}

///|
pub fn fixed_mean_014(values : Array[Double]) -> Double {
  if values.length() < 14 {
    abort("fixed_mean_014: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 14)..<values.length() {
    total = total + values[index]
  }
  total / 14.0
}

///|
pub fn fixed_mean_015(values : Array[Double]) -> Double {
  if values.length() < 15 {
    abort("fixed_mean_015: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 15)..<values.length() {
    total = total + values[index]
  }
  total / 15.0
}

///|
pub fn fixed_mean_016(values : Array[Double]) -> Double {
  if values.length() < 16 {
    abort("fixed_mean_016: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 16)..<values.length() {
    total = total + values[index]
  }
  total / 16.0
}

///|
pub fn fixed_mean_017(values : Array[Double]) -> Double {
  if values.length() < 17 {
    abort("fixed_mean_017: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 17)..<values.length() {
    total = total + values[index]
  }
  total / 17.0
}

///|
pub fn fixed_mean_018(values : Array[Double]) -> Double {
  if values.length() < 18 {
    abort("fixed_mean_018: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 18)..<values.length() {
    total = total + values[index]
  }
  total / 18.0
}

///|
pub fn fixed_mean_019(values : Array[Double]) -> Double {
  if values.length() < 19 {
    abort("fixed_mean_019: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 19)..<values.length() {
    total = total + values[index]
  }
  total / 19.0
}

///|
pub fn fixed_mean_020(values : Array[Double]) -> Double {
  if values.length() < 20 {
    abort("fixed_mean_020: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 20)..<values.length() {
    total = total + values[index]
  }
  total / 20.0
}

///|
pub fn fixed_mean_021(values : Array[Double]) -> Double {
  if values.length() < 21 {
    abort("fixed_mean_021: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 21)..<values.length() {
    total = total + values[index]
  }
  total / 21.0
}

///|
pub fn fixed_mean_022(values : Array[Double]) -> Double {
  if values.length() < 22 {
    abort("fixed_mean_022: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 22)..<values.length() {
    total = total + values[index]
  }
  total / 22.0
}

///|
pub fn fixed_mean_023(values : Array[Double]) -> Double {
  if values.length() < 23 {
    abort("fixed_mean_023: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 23)..<values.length() {
    total = total + values[index]
  }
  total / 23.0
}

///|
pub fn fixed_mean_024(values : Array[Double]) -> Double {
  if values.length() < 24 {
    abort("fixed_mean_024: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 24)..<values.length() {
    total = total + values[index]
  }
  total / 24.0
}

///|
pub fn fixed_mean_025(values : Array[Double]) -> Double {
  if values.length() < 25 {
    abort("fixed_mean_025: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 25)..<values.length() {
    total = total + values[index]
  }
  total / 25.0
}

///|
pub fn fixed_mean_026(values : Array[Double]) -> Double {
  if values.length() < 26 {
    abort("fixed_mean_026: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 26)..<values.length() {
    total = total + values[index]
  }
  total / 26.0
}

///|
pub fn fixed_mean_027(values : Array[Double]) -> Double {
  if values.length() < 27 {
    abort("fixed_mean_027: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 27)..<values.length() {
    total = total + values[index]
  }
  total / 27.0
}

///|
pub fn fixed_mean_028(values : Array[Double]) -> Double {
  if values.length() < 28 {
    abort("fixed_mean_028: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 28)..<values.length() {
    total = total + values[index]
  }
  total / 28.0
}

///|
pub fn fixed_mean_029(values : Array[Double]) -> Double {
  if values.length() < 29 {
    abort("fixed_mean_029: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 29)..<values.length() {
    total = total + values[index]
  }
  total / 29.0
}

///|
pub fn fixed_mean_030(values : Array[Double]) -> Double {
  if values.length() < 30 {
    abort("fixed_mean_030: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 30)..<values.length() {
    total = total + values[index]
  }
  total / 30.0
}

///|
pub fn fixed_mean_031(values : Array[Double]) -> Double {
  if values.length() < 31 {
    abort("fixed_mean_031: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 31)..<values.length() {
    total = total + values[index]
  }
  total / 31.0
}

///|
pub fn fixed_mean_032(values : Array[Double]) -> Double {
  if values.length() < 32 {
    abort("fixed_mean_032: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 32)..<values.length() {
    total = total + values[index]
  }
  total / 32.0
}

///|
pub fn fixed_mean_033(values : Array[Double]) -> Double {
  if values.length() < 33 {
    abort("fixed_mean_033: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 33)..<values.length() {
    total = total + values[index]
  }
  total / 33.0
}

///|
pub fn fixed_mean_034(values : Array[Double]) -> Double {
  if values.length() < 34 {
    abort("fixed_mean_034: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 34)..<values.length() {
    total = total + values[index]
  }
  total / 34.0
}

///|
pub fn fixed_mean_035(values : Array[Double]) -> Double {
  if values.length() < 35 {
    abort("fixed_mean_035: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 35)..<values.length() {
    total = total + values[index]
  }
  total / 35.0
}

///|
pub fn fixed_mean_036(values : Array[Double]) -> Double {
  if values.length() < 36 {
    abort("fixed_mean_036: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 36)..<values.length() {
    total = total + values[index]
  }
  total / 36.0
}

///|
pub fn fixed_mean_037(values : Array[Double]) -> Double {
  if values.length() < 37 {
    abort("fixed_mean_037: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 37)..<values.length() {
    total = total + values[index]
  }
  total / 37.0
}

///|
pub fn fixed_mean_038(values : Array[Double]) -> Double {
  if values.length() < 38 {
    abort("fixed_mean_038: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 38)..<values.length() {
    total = total + values[index]
  }
  total / 38.0
}

///|
pub fn fixed_mean_039(values : Array[Double]) -> Double {
  if values.length() < 39 {
    abort("fixed_mean_039: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 39)..<values.length() {
    total = total + values[index]
  }
  total / 39.0
}

///|
pub fn fixed_mean_040(values : Array[Double]) -> Double {
  if values.length() < 40 {
    abort("fixed_mean_040: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 40)..<values.length() {
    total = total + values[index]
  }
  total / 40.0
}

///|
pub fn fixed_mean_041(values : Array[Double]) -> Double {
  if values.length() < 41 {
    abort("fixed_mean_041: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 41)..<values.length() {
    total = total + values[index]
  }
  total / 41.0
}

///|
pub fn fixed_mean_042(values : Array[Double]) -> Double {
  if values.length() < 42 {
    abort("fixed_mean_042: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 42)..<values.length() {
    total = total + values[index]
  }
  total / 42.0
}

///|
pub fn fixed_mean_043(values : Array[Double]) -> Double {
  if values.length() < 43 {
    abort("fixed_mean_043: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 43)..<values.length() {
    total = total + values[index]
  }
  total / 43.0
}

///|
pub fn fixed_mean_044(values : Array[Double]) -> Double {
  if values.length() < 44 {
    abort("fixed_mean_044: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 44)..<values.length() {
    total = total + values[index]
  }
  total / 44.0
}

///|
pub fn fixed_mean_045(values : Array[Double]) -> Double {
  if values.length() < 45 {
    abort("fixed_mean_045: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 45)..<values.length() {
    total = total + values[index]
  }
  total / 45.0
}

///|
pub fn fixed_mean_046(values : Array[Double]) -> Double {
  if values.length() < 46 {
    abort("fixed_mean_046: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 46)..<values.length() {
    total = total + values[index]
  }
  total / 46.0
}

///|
pub fn fixed_mean_047(values : Array[Double]) -> Double {
  if values.length() < 47 {
    abort("fixed_mean_047: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 47)..<values.length() {
    total = total + values[index]
  }
  total / 47.0
}

///|
pub fn fixed_mean_048(values : Array[Double]) -> Double {
  if values.length() < 48 {
    abort("fixed_mean_048: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 48)..<values.length() {
    total = total + values[index]
  }
  total / 48.0
}

///|
pub fn fixed_mean_049(values : Array[Double]) -> Double {
  if values.length() < 49 {
    abort("fixed_mean_049: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 49)..<values.length() {
    total = total + values[index]
  }
  total / 49.0
}

///|
pub fn fixed_mean_050(values : Array[Double]) -> Double {
  if values.length() < 50 {
    abort("fixed_mean_050: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 50)..<values.length() {
    total = total + values[index]
  }
  total / 50.0
}

///|
pub fn fixed_mean_051(values : Array[Double]) -> Double {
  if values.length() < 51 {
    abort("fixed_mean_051: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 51)..<values.length() {
    total = total + values[index]
  }
  total / 51.0
}

///|
pub fn fixed_mean_052(values : Array[Double]) -> Double {
  if values.length() < 52 {
    abort("fixed_mean_052: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 52)..<values.length() {
    total = total + values[index]
  }
  total / 52.0
}

///|
pub fn fixed_mean_053(values : Array[Double]) -> Double {
  if values.length() < 53 {
    abort("fixed_mean_053: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 53)..<values.length() {
    total = total + values[index]
  }
  total / 53.0
}

///|
pub fn fixed_mean_054(values : Array[Double]) -> Double {
  if values.length() < 54 {
    abort("fixed_mean_054: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 54)..<values.length() {
    total = total + values[index]
  }
  total / 54.0
}

///|
pub fn fixed_mean_055(values : Array[Double]) -> Double {
  if values.length() < 55 {
    abort("fixed_mean_055: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 55)..<values.length() {
    total = total + values[index]
  }
  total / 55.0
}

///|
pub fn fixed_mean_056(values : Array[Double]) -> Double {
  if values.length() < 56 {
    abort("fixed_mean_056: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 56)..<values.length() {
    total = total + values[index]
  }
  total / 56.0
}

///|
pub fn fixed_mean_057(values : Array[Double]) -> Double {
  if values.length() < 57 {
    abort("fixed_mean_057: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 57)..<values.length() {
    total = total + values[index]
  }
  total / 57.0
}

///|
pub fn fixed_mean_058(values : Array[Double]) -> Double {
  if values.length() < 58 {
    abort("fixed_mean_058: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 58)..<values.length() {
    total = total + values[index]
  }
  total / 58.0
}

///|
pub fn fixed_mean_059(values : Array[Double]) -> Double {
  if values.length() < 59 {
    abort("fixed_mean_059: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 59)..<values.length() {
    total = total + values[index]
  }
  total / 59.0
}

///|
pub fn fixed_mean_060(values : Array[Double]) -> Double {
  if values.length() < 60 {
    abort("fixed_mean_060: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 60)..<values.length() {
    total = total + values[index]
  }
  total / 60.0
}

///|
pub fn fixed_mean_061(values : Array[Double]) -> Double {
  if values.length() < 61 {
    abort("fixed_mean_061: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 61)..<values.length() {
    total = total + values[index]
  }
  total / 61.0
}

///|
pub fn fixed_mean_062(values : Array[Double]) -> Double {
  if values.length() < 62 {
    abort("fixed_mean_062: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 62)..<values.length() {
    total = total + values[index]
  }
  total / 62.0
}

///|
pub fn fixed_mean_063(values : Array[Double]) -> Double {
  if values.length() < 63 {
    abort("fixed_mean_063: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 63)..<values.length() {
    total = total + values[index]
  }
  total / 63.0
}

///|
pub fn fixed_mean_064(values : Array[Double]) -> Double {
  if values.length() < 64 {
    abort("fixed_mean_064: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 64)..<values.length() {
    total = total + values[index]
  }
  total / 64.0
}

///|
pub fn fixed_mean_065(values : Array[Double]) -> Double {
  if values.length() < 65 {
    abort("fixed_mean_065: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 65)..<values.length() {
    total = total + values[index]
  }
  total / 65.0
}

///|
pub fn fixed_mean_066(values : Array[Double]) -> Double {
  if values.length() < 66 {
    abort("fixed_mean_066: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 66)..<values.length() {
    total = total + values[index]
  }
  total / 66.0
}

///|
pub fn fixed_mean_067(values : Array[Double]) -> Double {
  if values.length() < 67 {
    abort("fixed_mean_067: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 67)..<values.length() {
    total = total + values[index]
  }
  total / 67.0
}

///|
pub fn fixed_mean_068(values : Array[Double]) -> Double {
  if values.length() < 68 {
    abort("fixed_mean_068: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 68)..<values.length() {
    total = total + values[index]
  }
  total / 68.0
}

///|
pub fn fixed_mean_069(values : Array[Double]) -> Double {
  if values.length() < 69 {
    abort("fixed_mean_069: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 69)..<values.length() {
    total = total + values[index]
  }
  total / 69.0
}

///|
pub fn fixed_mean_070(values : Array[Double]) -> Double {
  if values.length() < 70 {
    abort("fixed_mean_070: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 70)..<values.length() {
    total = total + values[index]
  }
  total / 70.0
}

///|
pub fn fixed_mean_071(values : Array[Double]) -> Double {
  if values.length() < 71 {
    abort("fixed_mean_071: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 71)..<values.length() {
    total = total + values[index]
  }
  total / 71.0
}

///|
pub fn fixed_mean_072(values : Array[Double]) -> Double {
  if values.length() < 72 {
    abort("fixed_mean_072: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 72)..<values.length() {
    total = total + values[index]
  }
  total / 72.0
}

///|
pub fn fixed_mean_073(values : Array[Double]) -> Double {
  if values.length() < 73 {
    abort("fixed_mean_073: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 73)..<values.length() {
    total = total + values[index]
  }
  total / 73.0
}

///|
pub fn fixed_mean_074(values : Array[Double]) -> Double {
  if values.length() < 74 {
    abort("fixed_mean_074: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 74)..<values.length() {
    total = total + values[index]
  }
  total / 74.0
}

///|
pub fn fixed_mean_075(values : Array[Double]) -> Double {
  if values.length() < 75 {
    abort("fixed_mean_075: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 75)..<values.length() {
    total = total + values[index]
  }
  total / 75.0
}

///|
pub fn fixed_mean_076(values : Array[Double]) -> Double {
  if values.length() < 76 {
    abort("fixed_mean_076: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 76)..<values.length() {
    total = total + values[index]
  }
  total / 76.0
}

///|
pub fn fixed_mean_077(values : Array[Double]) -> Double {
  if values.length() < 77 {
    abort("fixed_mean_077: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 77)..<values.length() {
    total = total + values[index]
  }
  total / 77.0
}

///|
pub fn fixed_mean_078(values : Array[Double]) -> Double {
  if values.length() < 78 {
    abort("fixed_mean_078: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 78)..<values.length() {
    total = total + values[index]
  }
  total / 78.0
}

///|
pub fn fixed_mean_079(values : Array[Double]) -> Double {
  if values.length() < 79 {
    abort("fixed_mean_079: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 79)..<values.length() {
    total = total + values[index]
  }
  total / 79.0
}

///|
pub fn fixed_mean_080(values : Array[Double]) -> Double {
  if values.length() < 80 {
    abort("fixed_mean_080: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 80)..<values.length() {
    total = total + values[index]
  }
  total / 80.0
}

///|
pub fn fixed_mean_081(values : Array[Double]) -> Double {
  if values.length() < 81 {
    abort("fixed_mean_081: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 81)..<values.length() {
    total = total + values[index]
  }
  total / 81.0
}

///|
pub fn fixed_mean_082(values : Array[Double]) -> Double {
  if values.length() < 82 {
    abort("fixed_mean_082: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 82)..<values.length() {
    total = total + values[index]
  }
  total / 82.0
}

///|
pub fn fixed_mean_083(values : Array[Double]) -> Double {
  if values.length() < 83 {
    abort("fixed_mean_083: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 83)..<values.length() {
    total = total + values[index]
  }
  total / 83.0
}

///|
pub fn fixed_mean_084(values : Array[Double]) -> Double {
  if values.length() < 84 {
    abort("fixed_mean_084: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 84)..<values.length() {
    total = total + values[index]
  }
  total / 84.0
}

///|
pub fn fixed_mean_085(values : Array[Double]) -> Double {
  if values.length() < 85 {
    abort("fixed_mean_085: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 85)..<values.length() {
    total = total + values[index]
  }
  total / 85.0
}

///|
pub fn fixed_mean_086(values : Array[Double]) -> Double {
  if values.length() < 86 {
    abort("fixed_mean_086: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 86)..<values.length() {
    total = total + values[index]
  }
  total / 86.0
}

///|
pub fn fixed_mean_087(values : Array[Double]) -> Double {
  if values.length() < 87 {
    abort("fixed_mean_087: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 87)..<values.length() {
    total = total + values[index]
  }
  total / 87.0
}

///|
pub fn fixed_mean_088(values : Array[Double]) -> Double {
  if values.length() < 88 {
    abort("fixed_mean_088: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 88)..<values.length() {
    total = total + values[index]
  }
  total / 88.0
}

///|
pub fn fixed_mean_089(values : Array[Double]) -> Double {
  if values.length() < 89 {
    abort("fixed_mean_089: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 89)..<values.length() {
    total = total + values[index]
  }
  total / 89.0
}

///|
pub fn fixed_mean_090(values : Array[Double]) -> Double {
  if values.length() < 90 {
    abort("fixed_mean_090: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 90)..<values.length() {
    total = total + values[index]
  }
  total / 90.0
}

///|
pub fn fixed_mean_091(values : Array[Double]) -> Double {
  if values.length() < 91 {
    abort("fixed_mean_091: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 91)..<values.length() {
    total = total + values[index]
  }
  total / 91.0
}

///|
pub fn fixed_mean_092(values : Array[Double]) -> Double {
  if values.length() < 92 {
    abort("fixed_mean_092: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 92)..<values.length() {
    total = total + values[index]
  }
  total / 92.0
}

///|
pub fn fixed_mean_093(values : Array[Double]) -> Double {
  if values.length() < 93 {
    abort("fixed_mean_093: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 93)..<values.length() {
    total = total + values[index]
  }
  total / 93.0
}

///|
pub fn fixed_mean_094(values : Array[Double]) -> Double {
  if values.length() < 94 {
    abort("fixed_mean_094: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 94)..<values.length() {
    total = total + values[index]
  }
  total / 94.0
}

///|
pub fn fixed_mean_095(values : Array[Double]) -> Double {
  if values.length() < 95 {
    abort("fixed_mean_095: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 95)..<values.length() {
    total = total + values[index]
  }
  total / 95.0
}

///|
pub fn fixed_mean_096(values : Array[Double]) -> Double {
  if values.length() < 96 {
    abort("fixed_mean_096: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 96)..<values.length() {
    total = total + values[index]
  }
  total / 96.0
}

///|
pub fn fixed_mean_097(values : Array[Double]) -> Double {
  if values.length() < 97 {
    abort("fixed_mean_097: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 97)..<values.length() {
    total = total + values[index]
  }
  total / 97.0
}

///|
pub fn fixed_mean_098(values : Array[Double]) -> Double {
  if values.length() < 98 {
    abort("fixed_mean_098: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 98)..<values.length() {
    total = total + values[index]
  }
  total / 98.0
}

///|
pub fn fixed_mean_099(values : Array[Double]) -> Double {
  if values.length() < 99 {
    abort("fixed_mean_099: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 99)..<values.length() {
    total = total + values[index]
  }
  total / 99.0
}

///|
pub fn fixed_mean_100(values : Array[Double]) -> Double {
  if values.length() < 100 {
    abort("fixed_mean_100: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 100)..<values.length() {
    total = total + values[index]
  }
  total / 100.0
}

///|
pub fn fixed_mean_101(values : Array[Double]) -> Double {
  if values.length() < 101 {
    abort("fixed_mean_101: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 101)..<values.length() {
    total = total + values[index]
  }
  total / 101.0
}

///|
pub fn fixed_mean_102(values : Array[Double]) -> Double {
  if values.length() < 102 {
    abort("fixed_mean_102: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 102)..<values.length() {
    total = total + values[index]
  }
  total / 102.0
}

///|
pub fn fixed_mean_103(values : Array[Double]) -> Double {
  if values.length() < 103 {
    abort("fixed_mean_103: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 103)..<values.length() {
    total = total + values[index]
  }
  total / 103.0
}

///|
pub fn fixed_mean_104(values : Array[Double]) -> Double {
  if values.length() < 104 {
    abort("fixed_mean_104: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 104)..<values.length() {
    total = total + values[index]
  }
  total / 104.0
}

///|
pub fn fixed_mean_105(values : Array[Double]) -> Double {
  if values.length() < 105 {
    abort("fixed_mean_105: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 105)..<values.length() {
    total = total + values[index]
  }
  total / 105.0
}

///|
pub fn fixed_mean_106(values : Array[Double]) -> Double {
  if values.length() < 106 {
    abort("fixed_mean_106: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 106)..<values.length() {
    total = total + values[index]
  }
  total / 106.0
}

///|
pub fn fixed_mean_107(values : Array[Double]) -> Double {
  if values.length() < 107 {
    abort("fixed_mean_107: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 107)..<values.length() {
    total = total + values[index]
  }
  total / 107.0
}

///|
pub fn fixed_mean_108(values : Array[Double]) -> Double {
  if values.length() < 108 {
    abort("fixed_mean_108: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 108)..<values.length() {
    total = total + values[index]
  }
  total / 108.0
}

///|
pub fn fixed_mean_109(values : Array[Double]) -> Double {
  if values.length() < 109 {
    abort("fixed_mean_109: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 109)..<values.length() {
    total = total + values[index]
  }
  total / 109.0
}

///|
pub fn fixed_mean_110(values : Array[Double]) -> Double {
  if values.length() < 110 {
    abort("fixed_mean_110: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 110)..<values.length() {
    total = total + values[index]
  }
  total / 110.0
}

///|
pub fn fixed_mean_111(values : Array[Double]) -> Double {
  if values.length() < 111 {
    abort("fixed_mean_111: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 111)..<values.length() {
    total = total + values[index]
  }
  total / 111.0
}

///|
pub fn fixed_mean_112(values : Array[Double]) -> Double {
  if values.length() < 112 {
    abort("fixed_mean_112: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 112)..<values.length() {
    total = total + values[index]
  }
  total / 112.0
}

///|
pub fn fixed_mean_113(values : Array[Double]) -> Double {
  if values.length() < 113 {
    abort("fixed_mean_113: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 113)..<values.length() {
    total = total + values[index]
  }
  total / 113.0
}

///|
pub fn fixed_mean_114(values : Array[Double]) -> Double {
  if values.length() < 114 {
    abort("fixed_mean_114: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 114)..<values.length() {
    total = total + values[index]
  }
  total / 114.0
}

///|
pub fn fixed_mean_115(values : Array[Double]) -> Double {
  if values.length() < 115 {
    abort("fixed_mean_115: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 115)..<values.length() {
    total = total + values[index]
  }
  total / 115.0
}

///|
pub fn fixed_mean_116(values : Array[Double]) -> Double {
  if values.length() < 116 {
    abort("fixed_mean_116: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 116)..<values.length() {
    total = total + values[index]
  }
  total / 116.0
}

///|
pub fn fixed_mean_117(values : Array[Double]) -> Double {
  if values.length() < 117 {
    abort("fixed_mean_117: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 117)..<values.length() {
    total = total + values[index]
  }
  total / 117.0
}

///|
pub fn fixed_mean_118(values : Array[Double]) -> Double {
  if values.length() < 118 {
    abort("fixed_mean_118: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 118)..<values.length() {
    total = total + values[index]
  }
  total / 118.0
}

///|
pub fn fixed_mean_119(values : Array[Double]) -> Double {
  if values.length() < 119 {
    abort("fixed_mean_119: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 119)..<values.length() {
    total = total + values[index]
  }
  total / 119.0
}

///|
pub fn fixed_mean_120(values : Array[Double]) -> Double {
  if values.length() < 120 {
    abort("fixed_mean_120: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 120)..<values.length() {
    total = total + values[index]
  }
  total / 120.0
}

///|
pub fn fixed_mean_121(values : Array[Double]) -> Double {
  if values.length() < 121 {
    abort("fixed_mean_121: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 121)..<values.length() {
    total = total + values[index]
  }
  total / 121.0
}

///|
pub fn fixed_mean_122(values : Array[Double]) -> Double {
  if values.length() < 122 {
    abort("fixed_mean_122: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 122)..<values.length() {
    total = total + values[index]
  }
  total / 122.0
}

///|
pub fn fixed_mean_123(values : Array[Double]) -> Double {
  if values.length() < 123 {
    abort("fixed_mean_123: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 123)..<values.length() {
    total = total + values[index]
  }
  total / 123.0
}

///|
pub fn fixed_mean_124(values : Array[Double]) -> Double {
  if values.length() < 124 {
    abort("fixed_mean_124: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 124)..<values.length() {
    total = total + values[index]
  }
  total / 124.0
}

///|
pub fn fixed_mean_125(values : Array[Double]) -> Double {
  if values.length() < 125 {
    abort("fixed_mean_125: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 125)..<values.length() {
    total = total + values[index]
  }
  total / 125.0
}

///|
pub fn fixed_mean_126(values : Array[Double]) -> Double {
  if values.length() < 126 {
    abort("fixed_mean_126: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 126)..<values.length() {
    total = total + values[index]
  }
  total / 126.0
}

///|
pub fn fixed_mean_127(values : Array[Double]) -> Double {
  if values.length() < 127 {
    abort("fixed_mean_127: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 127)..<values.length() {
    total = total + values[index]
  }
  total / 127.0
}

///|
pub fn fixed_mean_128(values : Array[Double]) -> Double {
  if values.length() < 128 {
    abort("fixed_mean_128: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 128)..<values.length() {
    total = total + values[index]
  }
  total / 128.0
}

///|
pub fn fixed_mean_129(values : Array[Double]) -> Double {
  if values.length() < 129 {
    abort("fixed_mean_129: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 129)..<values.length() {
    total = total + values[index]
  }
  total / 129.0
}

///|
pub fn fixed_mean_130(values : Array[Double]) -> Double {
  if values.length() < 130 {
    abort("fixed_mean_130: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 130)..<values.length() {
    total = total + values[index]
  }
  total / 130.0
}

///|
pub fn fixed_mean_131(values : Array[Double]) -> Double {
  if values.length() < 131 {
    abort("fixed_mean_131: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 131)..<values.length() {
    total = total + values[index]
  }
  total / 131.0
}

///|
pub fn fixed_mean_132(values : Array[Double]) -> Double {
  if values.length() < 132 {
    abort("fixed_mean_132: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 132)..<values.length() {
    total = total + values[index]
  }
  total / 132.0
}

///|
pub fn fixed_mean_133(values : Array[Double]) -> Double {
  if values.length() < 133 {
    abort("fixed_mean_133: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 133)..<values.length() {
    total = total + values[index]
  }
  total / 133.0
}

///|
pub fn fixed_mean_134(values : Array[Double]) -> Double {
  if values.length() < 134 {
    abort("fixed_mean_134: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 134)..<values.length() {
    total = total + values[index]
  }
  total / 134.0
}

///|
pub fn fixed_mean_135(values : Array[Double]) -> Double {
  if values.length() < 135 {
    abort("fixed_mean_135: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 135)..<values.length() {
    total = total + values[index]
  }
  total / 135.0
}

///|
pub fn fixed_mean_136(values : Array[Double]) -> Double {
  if values.length() < 136 {
    abort("fixed_mean_136: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 136)..<values.length() {
    total = total + values[index]
  }
  total / 136.0
}

///|
pub fn fixed_mean_137(values : Array[Double]) -> Double {
  if values.length() < 137 {
    abort("fixed_mean_137: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 137)..<values.length() {
    total = total + values[index]
  }
  total / 137.0
}

///|
pub fn fixed_mean_138(values : Array[Double]) -> Double {
  if values.length() < 138 {
    abort("fixed_mean_138: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 138)..<values.length() {
    total = total + values[index]
  }
  total / 138.0
}

///|
pub fn fixed_mean_139(values : Array[Double]) -> Double {
  if values.length() < 139 {
    abort("fixed_mean_139: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 139)..<values.length() {
    total = total + values[index]
  }
  total / 139.0
}

///|
pub fn fixed_mean_140(values : Array[Double]) -> Double {
  if values.length() < 140 {
    abort("fixed_mean_140: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 140)..<values.length() {
    total = total + values[index]
  }
  total / 140.0
}

///|
pub fn fixed_mean_141(values : Array[Double]) -> Double {
  if values.length() < 141 {
    abort("fixed_mean_141: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 141)..<values.length() {
    total = total + values[index]
  }
  total / 141.0
}

///|
pub fn fixed_mean_142(values : Array[Double]) -> Double {
  if values.length() < 142 {
    abort("fixed_mean_142: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 142)..<values.length() {
    total = total + values[index]
  }
  total / 142.0
}

///|
pub fn fixed_mean_143(values : Array[Double]) -> Double {
  if values.length() < 143 {
    abort("fixed_mean_143: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 143)..<values.length() {
    total = total + values[index]
  }
  total / 143.0
}

///|
pub fn fixed_mean_144(values : Array[Double]) -> Double {
  if values.length() < 144 {
    abort("fixed_mean_144: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 144)..<values.length() {
    total = total + values[index]
  }
  total / 144.0
}

///|
pub fn fixed_mean_145(values : Array[Double]) -> Double {
  if values.length() < 145 {
    abort("fixed_mean_145: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 145)..<values.length() {
    total = total + values[index]
  }
  total / 145.0
}

///|
pub fn fixed_mean_146(values : Array[Double]) -> Double {
  if values.length() < 146 {
    abort("fixed_mean_146: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 146)..<values.length() {
    total = total + values[index]
  }
  total / 146.0
}

///|
pub fn fixed_mean_147(values : Array[Double]) -> Double {
  if values.length() < 147 {
    abort("fixed_mean_147: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 147)..<values.length() {
    total = total + values[index]
  }
  total / 147.0
}

///|
pub fn fixed_mean_148(values : Array[Double]) -> Double {
  if values.length() < 148 {
    abort("fixed_mean_148: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 148)..<values.length() {
    total = total + values[index]
  }
  total / 148.0
}

///|
pub fn fixed_mean_149(values : Array[Double]) -> Double {
  if values.length() < 149 {
    abort("fixed_mean_149: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 149)..<values.length() {
    total = total + values[index]
  }
  total / 149.0
}

///|
pub fn fixed_mean_150(values : Array[Double]) -> Double {
  if values.length() < 150 {
    abort("fixed_mean_150: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 150)..<values.length() {
    total = total + values[index]
  }
  total / 150.0
}

///|
pub fn fixed_mean_151(values : Array[Double]) -> Double {
  if values.length() < 151 {
    abort("fixed_mean_151: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 151)..<values.length() {
    total = total + values[index]
  }
  total / 151.0
}

///|
pub fn fixed_mean_152(values : Array[Double]) -> Double {
  if values.length() < 152 {
    abort("fixed_mean_152: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 152)..<values.length() {
    total = total + values[index]
  }
  total / 152.0
}

///|
pub fn fixed_mean_153(values : Array[Double]) -> Double {
  if values.length() < 153 {
    abort("fixed_mean_153: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 153)..<values.length() {
    total = total + values[index]
  }
  total / 153.0
}

///|
pub fn fixed_mean_154(values : Array[Double]) -> Double {
  if values.length() < 154 {
    abort("fixed_mean_154: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 154)..<values.length() {
    total = total + values[index]
  }
  total / 154.0
}

///|
pub fn fixed_mean_155(values : Array[Double]) -> Double {
  if values.length() < 155 {
    abort("fixed_mean_155: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 155)..<values.length() {
    total = total + values[index]
  }
  total / 155.0
}

///|
pub fn fixed_mean_156(values : Array[Double]) -> Double {
  if values.length() < 156 {
    abort("fixed_mean_156: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 156)..<values.length() {
    total = total + values[index]
  }
  total / 156.0
}

///|
pub fn fixed_mean_157(values : Array[Double]) -> Double {
  if values.length() < 157 {
    abort("fixed_mean_157: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 157)..<values.length() {
    total = total + values[index]
  }
  total / 157.0
}

///|
pub fn fixed_mean_158(values : Array[Double]) -> Double {
  if values.length() < 158 {
    abort("fixed_mean_158: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 158)..<values.length() {
    total = total + values[index]
  }
  total / 158.0
}

///|
pub fn fixed_mean_159(values : Array[Double]) -> Double {
  if values.length() < 159 {
    abort("fixed_mean_159: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 159)..<values.length() {
    total = total + values[index]
  }
  total / 159.0
}

///|
pub fn fixed_mean_160(values : Array[Double]) -> Double {
  if values.length() < 160 {
    abort("fixed_mean_160: insufficient values")
  }
  let mut total = 0.0
  for index in (values.length() - 160)..<values.length() {
    total = total + values[index]
  }
  total / 160.0
}

///|
pub fn fixed_variance_001(values : Array[Double]) -> Double {
  if values.length() < 1 {
    abort("fixed_variance_001: insufficient values")
  }
  let center = fixed_mean_001(values)
  let mut total = 0.0
  for index in (values.length() - 1)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 1.0
}

///|
pub fn fixed_variance_002(values : Array[Double]) -> Double {
  if values.length() < 2 {
    abort("fixed_variance_002: insufficient values")
  }
  let center = fixed_mean_002(values)
  let mut total = 0.0
  for index in (values.length() - 2)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 2.0
}

///|
pub fn fixed_variance_003(values : Array[Double]) -> Double {
  if values.length() < 3 {
    abort("fixed_variance_003: insufficient values")
  }
  let center = fixed_mean_003(values)
  let mut total = 0.0
  for index in (values.length() - 3)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 3.0
}

///|
pub fn fixed_variance_004(values : Array[Double]) -> Double {
  if values.length() < 4 {
    abort("fixed_variance_004: insufficient values")
  }
  let center = fixed_mean_004(values)
  let mut total = 0.0
  for index in (values.length() - 4)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 4.0
}

///|
pub fn fixed_variance_005(values : Array[Double]) -> Double {
  if values.length() < 5 {
    abort("fixed_variance_005: insufficient values")
  }
  let center = fixed_mean_005(values)
  let mut total = 0.0
  for index in (values.length() - 5)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 5.0
}

///|
pub fn fixed_variance_006(values : Array[Double]) -> Double {
  if values.length() < 6 {
    abort("fixed_variance_006: insufficient values")
  }
  let center = fixed_mean_006(values)
  let mut total = 0.0
  for index in (values.length() - 6)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 6.0
}

///|
pub fn fixed_variance_007(values : Array[Double]) -> Double {
  if values.length() < 7 {
    abort("fixed_variance_007: insufficient values")
  }
  let center = fixed_mean_007(values)
  let mut total = 0.0
  for index in (values.length() - 7)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 7.0
}

///|
pub fn fixed_variance_008(values : Array[Double]) -> Double {
  if values.length() < 8 {
    abort("fixed_variance_008: insufficient values")
  }
  let center = fixed_mean_008(values)
  let mut total = 0.0
  for index in (values.length() - 8)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 8.0
}

///|
pub fn fixed_variance_009(values : Array[Double]) -> Double {
  if values.length() < 9 {
    abort("fixed_variance_009: insufficient values")
  }
  let center = fixed_mean_009(values)
  let mut total = 0.0
  for index in (values.length() - 9)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 9.0
}

///|
pub fn fixed_variance_010(values : Array[Double]) -> Double {
  if values.length() < 10 {
    abort("fixed_variance_010: insufficient values")
  }
  let center = fixed_mean_010(values)
  let mut total = 0.0
  for index in (values.length() - 10)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 10.0
}

///|
pub fn fixed_variance_011(values : Array[Double]) -> Double {
  if values.length() < 11 {
    abort("fixed_variance_011: insufficient values")
  }
  let center = fixed_mean_011(values)
  let mut total = 0.0
  for index in (values.length() - 11)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 11.0
}

///|
pub fn fixed_variance_012(values : Array[Double]) -> Double {
  if values.length() < 12 {
    abort("fixed_variance_012: insufficient values")
  }
  let center = fixed_mean_012(values)
  let mut total = 0.0
  for index in (values.length() - 12)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 12.0
}

///|
pub fn fixed_variance_013(values : Array[Double]) -> Double {
  if values.length() < 13 {
    abort("fixed_variance_013: insufficient values")
  }
  let center = fixed_mean_013(values)
  let mut total = 0.0
  for index in (values.length() - 13)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 13.0
}

///|
pub fn fixed_variance_014(values : Array[Double]) -> Double {
  if values.length() < 14 {
    abort("fixed_variance_014: insufficient values")
  }
  let center = fixed_mean_014(values)
  let mut total = 0.0
  for index in (values.length() - 14)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 14.0
}

///|
pub fn fixed_variance_015(values : Array[Double]) -> Double {
  if values.length() < 15 {
    abort("fixed_variance_015: insufficient values")
  }
  let center = fixed_mean_015(values)
  let mut total = 0.0
  for index in (values.length() - 15)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 15.0
}

///|
pub fn fixed_variance_016(values : Array[Double]) -> Double {
  if values.length() < 16 {
    abort("fixed_variance_016: insufficient values")
  }
  let center = fixed_mean_016(values)
  let mut total = 0.0
  for index in (values.length() - 16)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 16.0
}

///|
pub fn fixed_variance_017(values : Array[Double]) -> Double {
  if values.length() < 17 {
    abort("fixed_variance_017: insufficient values")
  }
  let center = fixed_mean_017(values)
  let mut total = 0.0
  for index in (values.length() - 17)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 17.0
}

///|
pub fn fixed_variance_018(values : Array[Double]) -> Double {
  if values.length() < 18 {
    abort("fixed_variance_018: insufficient values")
  }
  let center = fixed_mean_018(values)
  let mut total = 0.0
  for index in (values.length() - 18)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 18.0
}

///|
pub fn fixed_variance_019(values : Array[Double]) -> Double {
  if values.length() < 19 {
    abort("fixed_variance_019: insufficient values")
  }
  let center = fixed_mean_019(values)
  let mut total = 0.0
  for index in (values.length() - 19)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 19.0
}

///|
pub fn fixed_variance_020(values : Array[Double]) -> Double {
  if values.length() < 20 {
    abort("fixed_variance_020: insufficient values")
  }
  let center = fixed_mean_020(values)
  let mut total = 0.0
  for index in (values.length() - 20)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 20.0
}

///|
pub fn fixed_variance_021(values : Array[Double]) -> Double {
  if values.length() < 21 {
    abort("fixed_variance_021: insufficient values")
  }
  let center = fixed_mean_021(values)
  let mut total = 0.0
  for index in (values.length() - 21)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 21.0
}

///|
pub fn fixed_variance_022(values : Array[Double]) -> Double {
  if values.length() < 22 {
    abort("fixed_variance_022: insufficient values")
  }
  let center = fixed_mean_022(values)
  let mut total = 0.0
  for index in (values.length() - 22)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 22.0
}

///|
pub fn fixed_variance_023(values : Array[Double]) -> Double {
  if values.length() < 23 {
    abort("fixed_variance_023: insufficient values")
  }
  let center = fixed_mean_023(values)
  let mut total = 0.0
  for index in (values.length() - 23)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 23.0
}

///|
pub fn fixed_variance_024(values : Array[Double]) -> Double {
  if values.length() < 24 {
    abort("fixed_variance_024: insufficient values")
  }
  let center = fixed_mean_024(values)
  let mut total = 0.0
  for index in (values.length() - 24)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 24.0
}

///|
pub fn fixed_variance_025(values : Array[Double]) -> Double {
  if values.length() < 25 {
    abort("fixed_variance_025: insufficient values")
  }
  let center = fixed_mean_025(values)
  let mut total = 0.0
  for index in (values.length() - 25)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 25.0
}

///|
pub fn fixed_variance_026(values : Array[Double]) -> Double {
  if values.length() < 26 {
    abort("fixed_variance_026: insufficient values")
  }
  let center = fixed_mean_026(values)
  let mut total = 0.0
  for index in (values.length() - 26)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 26.0
}

///|
pub fn fixed_variance_027(values : Array[Double]) -> Double {
  if values.length() < 27 {
    abort("fixed_variance_027: insufficient values")
  }
  let center = fixed_mean_027(values)
  let mut total = 0.0
  for index in (values.length() - 27)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 27.0
}

///|
pub fn fixed_variance_028(values : Array[Double]) -> Double {
  if values.length() < 28 {
    abort("fixed_variance_028: insufficient values")
  }
  let center = fixed_mean_028(values)
  let mut total = 0.0
  for index in (values.length() - 28)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 28.0
}

///|
pub fn fixed_variance_029(values : Array[Double]) -> Double {
  if values.length() < 29 {
    abort("fixed_variance_029: insufficient values")
  }
  let center = fixed_mean_029(values)
  let mut total = 0.0
  for index in (values.length() - 29)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 29.0
}

///|
pub fn fixed_variance_030(values : Array[Double]) -> Double {
  if values.length() < 30 {
    abort("fixed_variance_030: insufficient values")
  }
  let center = fixed_mean_030(values)
  let mut total = 0.0
  for index in (values.length() - 30)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 30.0
}

///|
pub fn fixed_variance_031(values : Array[Double]) -> Double {
  if values.length() < 31 {
    abort("fixed_variance_031: insufficient values")
  }
  let center = fixed_mean_031(values)
  let mut total = 0.0
  for index in (values.length() - 31)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 31.0
}

///|
pub fn fixed_variance_032(values : Array[Double]) -> Double {
  if values.length() < 32 {
    abort("fixed_variance_032: insufficient values")
  }
  let center = fixed_mean_032(values)
  let mut total = 0.0
  for index in (values.length() - 32)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 32.0
}

///|
pub fn fixed_variance_033(values : Array[Double]) -> Double {
  if values.length() < 33 {
    abort("fixed_variance_033: insufficient values")
  }
  let center = fixed_mean_033(values)
  let mut total = 0.0
  for index in (values.length() - 33)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 33.0
}

///|
pub fn fixed_variance_034(values : Array[Double]) -> Double {
  if values.length() < 34 {
    abort("fixed_variance_034: insufficient values")
  }
  let center = fixed_mean_034(values)
  let mut total = 0.0
  for index in (values.length() - 34)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 34.0
}

///|
pub fn fixed_variance_035(values : Array[Double]) -> Double {
  if values.length() < 35 {
    abort("fixed_variance_035: insufficient values")
  }
  let center = fixed_mean_035(values)
  let mut total = 0.0
  for index in (values.length() - 35)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 35.0
}

///|
pub fn fixed_variance_036(values : Array[Double]) -> Double {
  if values.length() < 36 {
    abort("fixed_variance_036: insufficient values")
  }
  let center = fixed_mean_036(values)
  let mut total = 0.0
  for index in (values.length() - 36)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 36.0
}

///|
pub fn fixed_variance_037(values : Array[Double]) -> Double {
  if values.length() < 37 {
    abort("fixed_variance_037: insufficient values")
  }
  let center = fixed_mean_037(values)
  let mut total = 0.0
  for index in (values.length() - 37)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 37.0
}

///|
pub fn fixed_variance_038(values : Array[Double]) -> Double {
  if values.length() < 38 {
    abort("fixed_variance_038: insufficient values")
  }
  let center = fixed_mean_038(values)
  let mut total = 0.0
  for index in (values.length() - 38)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 38.0
}

///|
pub fn fixed_variance_039(values : Array[Double]) -> Double {
  if values.length() < 39 {
    abort("fixed_variance_039: insufficient values")
  }
  let center = fixed_mean_039(values)
  let mut total = 0.0
  for index in (values.length() - 39)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 39.0
}

///|
pub fn fixed_variance_040(values : Array[Double]) -> Double {
  if values.length() < 40 {
    abort("fixed_variance_040: insufficient values")
  }
  let center = fixed_mean_040(values)
  let mut total = 0.0
  for index in (values.length() - 40)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 40.0
}

///|
pub fn fixed_variance_041(values : Array[Double]) -> Double {
  if values.length() < 41 {
    abort("fixed_variance_041: insufficient values")
  }
  let center = fixed_mean_041(values)
  let mut total = 0.0
  for index in (values.length() - 41)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 41.0
}

///|
pub fn fixed_variance_042(values : Array[Double]) -> Double {
  if values.length() < 42 {
    abort("fixed_variance_042: insufficient values")
  }
  let center = fixed_mean_042(values)
  let mut total = 0.0
  for index in (values.length() - 42)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 42.0
}

///|
pub fn fixed_variance_043(values : Array[Double]) -> Double {
  if values.length() < 43 {
    abort("fixed_variance_043: insufficient values")
  }
  let center = fixed_mean_043(values)
  let mut total = 0.0
  for index in (values.length() - 43)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 43.0
}

///|
pub fn fixed_variance_044(values : Array[Double]) -> Double {
  if values.length() < 44 {
    abort("fixed_variance_044: insufficient values")
  }
  let center = fixed_mean_044(values)
  let mut total = 0.0
  for index in (values.length() - 44)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 44.0
}

///|
pub fn fixed_variance_045(values : Array[Double]) -> Double {
  if values.length() < 45 {
    abort("fixed_variance_045: insufficient values")
  }
  let center = fixed_mean_045(values)
  let mut total = 0.0
  for index in (values.length() - 45)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 45.0
}

///|
pub fn fixed_variance_046(values : Array[Double]) -> Double {
  if values.length() < 46 {
    abort("fixed_variance_046: insufficient values")
  }
  let center = fixed_mean_046(values)
  let mut total = 0.0
  for index in (values.length() - 46)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 46.0
}

///|
pub fn fixed_variance_047(values : Array[Double]) -> Double {
  if values.length() < 47 {
    abort("fixed_variance_047: insufficient values")
  }
  let center = fixed_mean_047(values)
  let mut total = 0.0
  for index in (values.length() - 47)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 47.0
}

///|
pub fn fixed_variance_048(values : Array[Double]) -> Double {
  if values.length() < 48 {
    abort("fixed_variance_048: insufficient values")
  }
  let center = fixed_mean_048(values)
  let mut total = 0.0
  for index in (values.length() - 48)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 48.0
}

///|
pub fn fixed_variance_049(values : Array[Double]) -> Double {
  if values.length() < 49 {
    abort("fixed_variance_049: insufficient values")
  }
  let center = fixed_mean_049(values)
  let mut total = 0.0
  for index in (values.length() - 49)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 49.0
}

///|
pub fn fixed_variance_050(values : Array[Double]) -> Double {
  if values.length() < 50 {
    abort("fixed_variance_050: insufficient values")
  }
  let center = fixed_mean_050(values)
  let mut total = 0.0
  for index in (values.length() - 50)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 50.0
}

///|
pub fn fixed_variance_051(values : Array[Double]) -> Double {
  if values.length() < 51 {
    abort("fixed_variance_051: insufficient values")
  }
  let center = fixed_mean_051(values)
  let mut total = 0.0
  for index in (values.length() - 51)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 51.0
}

///|
pub fn fixed_variance_052(values : Array[Double]) -> Double {
  if values.length() < 52 {
    abort("fixed_variance_052: insufficient values")
  }
  let center = fixed_mean_052(values)
  let mut total = 0.0
  for index in (values.length() - 52)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 52.0
}

///|
pub fn fixed_variance_053(values : Array[Double]) -> Double {
  if values.length() < 53 {
    abort("fixed_variance_053: insufficient values")
  }
  let center = fixed_mean_053(values)
  let mut total = 0.0
  for index in (values.length() - 53)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 53.0
}

///|
pub fn fixed_variance_054(values : Array[Double]) -> Double {
  if values.length() < 54 {
    abort("fixed_variance_054: insufficient values")
  }
  let center = fixed_mean_054(values)
  let mut total = 0.0
  for index in (values.length() - 54)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 54.0
}

///|
pub fn fixed_variance_055(values : Array[Double]) -> Double {
  if values.length() < 55 {
    abort("fixed_variance_055: insufficient values")
  }
  let center = fixed_mean_055(values)
  let mut total = 0.0
  for index in (values.length() - 55)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 55.0
}

///|
pub fn fixed_variance_056(values : Array[Double]) -> Double {
  if values.length() < 56 {
    abort("fixed_variance_056: insufficient values")
  }
  let center = fixed_mean_056(values)
  let mut total = 0.0
  for index in (values.length() - 56)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 56.0
}

///|
pub fn fixed_variance_057(values : Array[Double]) -> Double {
  if values.length() < 57 {
    abort("fixed_variance_057: insufficient values")
  }
  let center = fixed_mean_057(values)
  let mut total = 0.0
  for index in (values.length() - 57)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 57.0
}

///|
pub fn fixed_variance_058(values : Array[Double]) -> Double {
  if values.length() < 58 {
    abort("fixed_variance_058: insufficient values")
  }
  let center = fixed_mean_058(values)
  let mut total = 0.0
  for index in (values.length() - 58)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 58.0
}

///|
pub fn fixed_variance_059(values : Array[Double]) -> Double {
  if values.length() < 59 {
    abort("fixed_variance_059: insufficient values")
  }
  let center = fixed_mean_059(values)
  let mut total = 0.0
  for index in (values.length() - 59)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 59.0
}

///|
pub fn fixed_variance_060(values : Array[Double]) -> Double {
  if values.length() < 60 {
    abort("fixed_variance_060: insufficient values")
  }
  let center = fixed_mean_060(values)
  let mut total = 0.0
  for index in (values.length() - 60)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 60.0
}

///|
pub fn fixed_variance_061(values : Array[Double]) -> Double {
  if values.length() < 61 {
    abort("fixed_variance_061: insufficient values")
  }
  let center = fixed_mean_061(values)
  let mut total = 0.0
  for index in (values.length() - 61)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 61.0
}

///|
pub fn fixed_variance_062(values : Array[Double]) -> Double {
  if values.length() < 62 {
    abort("fixed_variance_062: insufficient values")
  }
  let center = fixed_mean_062(values)
  let mut total = 0.0
  for index in (values.length() - 62)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 62.0
}

///|
pub fn fixed_variance_063(values : Array[Double]) -> Double {
  if values.length() < 63 {
    abort("fixed_variance_063: insufficient values")
  }
  let center = fixed_mean_063(values)
  let mut total = 0.0
  for index in (values.length() - 63)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 63.0
}

///|
pub fn fixed_variance_064(values : Array[Double]) -> Double {
  if values.length() < 64 {
    abort("fixed_variance_064: insufficient values")
  }
  let center = fixed_mean_064(values)
  let mut total = 0.0
  for index in (values.length() - 64)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 64.0
}

///|
pub fn fixed_variance_065(values : Array[Double]) -> Double {
  if values.length() < 65 {
    abort("fixed_variance_065: insufficient values")
  }
  let center = fixed_mean_065(values)
  let mut total = 0.0
  for index in (values.length() - 65)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 65.0
}

///|
pub fn fixed_variance_066(values : Array[Double]) -> Double {
  if values.length() < 66 {
    abort("fixed_variance_066: insufficient values")
  }
  let center = fixed_mean_066(values)
  let mut total = 0.0
  for index in (values.length() - 66)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 66.0
}

///|
pub fn fixed_variance_067(values : Array[Double]) -> Double {
  if values.length() < 67 {
    abort("fixed_variance_067: insufficient values")
  }
  let center = fixed_mean_067(values)
  let mut total = 0.0
  for index in (values.length() - 67)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 67.0
}

///|
pub fn fixed_variance_068(values : Array[Double]) -> Double {
  if values.length() < 68 {
    abort("fixed_variance_068: insufficient values")
  }
  let center = fixed_mean_068(values)
  let mut total = 0.0
  for index in (values.length() - 68)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 68.0
}

///|
pub fn fixed_variance_069(values : Array[Double]) -> Double {
  if values.length() < 69 {
    abort("fixed_variance_069: insufficient values")
  }
  let center = fixed_mean_069(values)
  let mut total = 0.0
  for index in (values.length() - 69)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 69.0
}

///|
pub fn fixed_variance_070(values : Array[Double]) -> Double {
  if values.length() < 70 {
    abort("fixed_variance_070: insufficient values")
  }
  let center = fixed_mean_070(values)
  let mut total = 0.0
  for index in (values.length() - 70)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 70.0
}

///|
pub fn fixed_variance_071(values : Array[Double]) -> Double {
  if values.length() < 71 {
    abort("fixed_variance_071: insufficient values")
  }
  let center = fixed_mean_071(values)
  let mut total = 0.0
  for index in (values.length() - 71)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 71.0
}

///|
pub fn fixed_variance_072(values : Array[Double]) -> Double {
  if values.length() < 72 {
    abort("fixed_variance_072: insufficient values")
  }
  let center = fixed_mean_072(values)
  let mut total = 0.0
  for index in (values.length() - 72)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 72.0
}

///|
pub fn fixed_variance_073(values : Array[Double]) -> Double {
  if values.length() < 73 {
    abort("fixed_variance_073: insufficient values")
  }
  let center = fixed_mean_073(values)
  let mut total = 0.0
  for index in (values.length() - 73)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 73.0
}

///|
pub fn fixed_variance_074(values : Array[Double]) -> Double {
  if values.length() < 74 {
    abort("fixed_variance_074: insufficient values")
  }
  let center = fixed_mean_074(values)
  let mut total = 0.0
  for index in (values.length() - 74)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 74.0
}

///|
pub fn fixed_variance_075(values : Array[Double]) -> Double {
  if values.length() < 75 {
    abort("fixed_variance_075: insufficient values")
  }
  let center = fixed_mean_075(values)
  let mut total = 0.0
  for index in (values.length() - 75)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 75.0
}

///|
pub fn fixed_variance_076(values : Array[Double]) -> Double {
  if values.length() < 76 {
    abort("fixed_variance_076: insufficient values")
  }
  let center = fixed_mean_076(values)
  let mut total = 0.0
  for index in (values.length() - 76)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 76.0
}

///|
pub fn fixed_variance_077(values : Array[Double]) -> Double {
  if values.length() < 77 {
    abort("fixed_variance_077: insufficient values")
  }
  let center = fixed_mean_077(values)
  let mut total = 0.0
  for index in (values.length() - 77)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 77.0
}

///|
pub fn fixed_variance_078(values : Array[Double]) -> Double {
  if values.length() < 78 {
    abort("fixed_variance_078: insufficient values")
  }
  let center = fixed_mean_078(values)
  let mut total = 0.0
  for index in (values.length() - 78)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 78.0
}

///|
pub fn fixed_variance_079(values : Array[Double]) -> Double {
  if values.length() < 79 {
    abort("fixed_variance_079: insufficient values")
  }
  let center = fixed_mean_079(values)
  let mut total = 0.0
  for index in (values.length() - 79)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 79.0
}

///|
pub fn fixed_variance_080(values : Array[Double]) -> Double {
  if values.length() < 80 {
    abort("fixed_variance_080: insufficient values")
  }
  let center = fixed_mean_080(values)
  let mut total = 0.0
  for index in (values.length() - 80)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 80.0
}

///|
pub fn fixed_variance_081(values : Array[Double]) -> Double {
  if values.length() < 81 {
    abort("fixed_variance_081: insufficient values")
  }
  let center = fixed_mean_081(values)
  let mut total = 0.0
  for index in (values.length() - 81)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 81.0
}

///|
pub fn fixed_variance_082(values : Array[Double]) -> Double {
  if values.length() < 82 {
    abort("fixed_variance_082: insufficient values")
  }
  let center = fixed_mean_082(values)
  let mut total = 0.0
  for index in (values.length() - 82)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 82.0
}

///|
pub fn fixed_variance_083(values : Array[Double]) -> Double {
  if values.length() < 83 {
    abort("fixed_variance_083: insufficient values")
  }
  let center = fixed_mean_083(values)
  let mut total = 0.0
  for index in (values.length() - 83)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 83.0
}

///|
pub fn fixed_variance_084(values : Array[Double]) -> Double {
  if values.length() < 84 {
    abort("fixed_variance_084: insufficient values")
  }
  let center = fixed_mean_084(values)
  let mut total = 0.0
  for index in (values.length() - 84)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 84.0
}

///|
pub fn fixed_variance_085(values : Array[Double]) -> Double {
  if values.length() < 85 {
    abort("fixed_variance_085: insufficient values")
  }
  let center = fixed_mean_085(values)
  let mut total = 0.0
  for index in (values.length() - 85)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 85.0
}

///|
pub fn fixed_variance_086(values : Array[Double]) -> Double {
  if values.length() < 86 {
    abort("fixed_variance_086: insufficient values")
  }
  let center = fixed_mean_086(values)
  let mut total = 0.0
  for index in (values.length() - 86)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 86.0
}

///|
pub fn fixed_variance_087(values : Array[Double]) -> Double {
  if values.length() < 87 {
    abort("fixed_variance_087: insufficient values")
  }
  let center = fixed_mean_087(values)
  let mut total = 0.0
  for index in (values.length() - 87)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 87.0
}

///|
pub fn fixed_variance_088(values : Array[Double]) -> Double {
  if values.length() < 88 {
    abort("fixed_variance_088: insufficient values")
  }
  let center = fixed_mean_088(values)
  let mut total = 0.0
  for index in (values.length() - 88)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 88.0
}

///|
pub fn fixed_variance_089(values : Array[Double]) -> Double {
  if values.length() < 89 {
    abort("fixed_variance_089: insufficient values")
  }
  let center = fixed_mean_089(values)
  let mut total = 0.0
  for index in (values.length() - 89)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 89.0
}

///|
pub fn fixed_variance_090(values : Array[Double]) -> Double {
  if values.length() < 90 {
    abort("fixed_variance_090: insufficient values")
  }
  let center = fixed_mean_090(values)
  let mut total = 0.0
  for index in (values.length() - 90)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 90.0
}

///|
pub fn fixed_variance_091(values : Array[Double]) -> Double {
  if values.length() < 91 {
    abort("fixed_variance_091: insufficient values")
  }
  let center = fixed_mean_091(values)
  let mut total = 0.0
  for index in (values.length() - 91)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 91.0
}

///|
pub fn fixed_variance_092(values : Array[Double]) -> Double {
  if values.length() < 92 {
    abort("fixed_variance_092: insufficient values")
  }
  let center = fixed_mean_092(values)
  let mut total = 0.0
  for index in (values.length() - 92)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 92.0
}

///|
pub fn fixed_variance_093(values : Array[Double]) -> Double {
  if values.length() < 93 {
    abort("fixed_variance_093: insufficient values")
  }
  let center = fixed_mean_093(values)
  let mut total = 0.0
  for index in (values.length() - 93)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 93.0
}

///|
pub fn fixed_variance_094(values : Array[Double]) -> Double {
  if values.length() < 94 {
    abort("fixed_variance_094: insufficient values")
  }
  let center = fixed_mean_094(values)
  let mut total = 0.0
  for index in (values.length() - 94)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 94.0
}

///|
pub fn fixed_variance_095(values : Array[Double]) -> Double {
  if values.length() < 95 {
    abort("fixed_variance_095: insufficient values")
  }
  let center = fixed_mean_095(values)
  let mut total = 0.0
  for index in (values.length() - 95)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 95.0
}

///|
pub fn fixed_variance_096(values : Array[Double]) -> Double {
  if values.length() < 96 {
    abort("fixed_variance_096: insufficient values")
  }
  let center = fixed_mean_096(values)
  let mut total = 0.0
  for index in (values.length() - 96)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 96.0
}

///|
pub fn fixed_variance_097(values : Array[Double]) -> Double {
  if values.length() < 97 {
    abort("fixed_variance_097: insufficient values")
  }
  let center = fixed_mean_097(values)
  let mut total = 0.0
  for index in (values.length() - 97)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 97.0
}

///|
pub fn fixed_variance_098(values : Array[Double]) -> Double {
  if values.length() < 98 {
    abort("fixed_variance_098: insufficient values")
  }
  let center = fixed_mean_098(values)
  let mut total = 0.0
  for index in (values.length() - 98)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 98.0
}

///|
pub fn fixed_variance_099(values : Array[Double]) -> Double {
  if values.length() < 99 {
    abort("fixed_variance_099: insufficient values")
  }
  let center = fixed_mean_099(values)
  let mut total = 0.0
  for index in (values.length() - 99)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 99.0
}

///|
pub fn fixed_variance_100(values : Array[Double]) -> Double {
  if values.length() < 100 {
    abort("fixed_variance_100: insufficient values")
  }
  let center = fixed_mean_100(values)
  let mut total = 0.0
  for index in (values.length() - 100)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 100.0
}

///|
pub fn fixed_variance_101(values : Array[Double]) -> Double {
  if values.length() < 101 {
    abort("fixed_variance_101: insufficient values")
  }
  let center = fixed_mean_101(values)
  let mut total = 0.0
  for index in (values.length() - 101)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 101.0
}

///|
pub fn fixed_variance_102(values : Array[Double]) -> Double {
  if values.length() < 102 {
    abort("fixed_variance_102: insufficient values")
  }
  let center = fixed_mean_102(values)
  let mut total = 0.0
  for index in (values.length() - 102)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 102.0
}

///|
pub fn fixed_variance_103(values : Array[Double]) -> Double {
  if values.length() < 103 {
    abort("fixed_variance_103: insufficient values")
  }
  let center = fixed_mean_103(values)
  let mut total = 0.0
  for index in (values.length() - 103)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 103.0
}

///|
pub fn fixed_variance_104(values : Array[Double]) -> Double {
  if values.length() < 104 {
    abort("fixed_variance_104: insufficient values")
  }
  let center = fixed_mean_104(values)
  let mut total = 0.0
  for index in (values.length() - 104)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 104.0
}

///|
pub fn fixed_variance_105(values : Array[Double]) -> Double {
  if values.length() < 105 {
    abort("fixed_variance_105: insufficient values")
  }
  let center = fixed_mean_105(values)
  let mut total = 0.0
  for index in (values.length() - 105)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 105.0
}

///|
pub fn fixed_variance_106(values : Array[Double]) -> Double {
  if values.length() < 106 {
    abort("fixed_variance_106: insufficient values")
  }
  let center = fixed_mean_106(values)
  let mut total = 0.0
  for index in (values.length() - 106)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 106.0
}

///|
pub fn fixed_variance_107(values : Array[Double]) -> Double {
  if values.length() < 107 {
    abort("fixed_variance_107: insufficient values")
  }
  let center = fixed_mean_107(values)
  let mut total = 0.0
  for index in (values.length() - 107)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 107.0
}

///|
pub fn fixed_variance_108(values : Array[Double]) -> Double {
  if values.length() < 108 {
    abort("fixed_variance_108: insufficient values")
  }
  let center = fixed_mean_108(values)
  let mut total = 0.0
  for index in (values.length() - 108)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 108.0
}

///|
pub fn fixed_variance_109(values : Array[Double]) -> Double {
  if values.length() < 109 {
    abort("fixed_variance_109: insufficient values")
  }
  let center = fixed_mean_109(values)
  let mut total = 0.0
  for index in (values.length() - 109)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 109.0
}

///|
pub fn fixed_variance_110(values : Array[Double]) -> Double {
  if values.length() < 110 {
    abort("fixed_variance_110: insufficient values")
  }
  let center = fixed_mean_110(values)
  let mut total = 0.0
  for index in (values.length() - 110)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 110.0
}

///|
pub fn fixed_variance_111(values : Array[Double]) -> Double {
  if values.length() < 111 {
    abort("fixed_variance_111: insufficient values")
  }
  let center = fixed_mean_111(values)
  let mut total = 0.0
  for index in (values.length() - 111)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 111.0
}

///|
pub fn fixed_variance_112(values : Array[Double]) -> Double {
  if values.length() < 112 {
    abort("fixed_variance_112: insufficient values")
  }
  let center = fixed_mean_112(values)
  let mut total = 0.0
  for index in (values.length() - 112)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 112.0
}

///|
pub fn fixed_variance_113(values : Array[Double]) -> Double {
  if values.length() < 113 {
    abort("fixed_variance_113: insufficient values")
  }
  let center = fixed_mean_113(values)
  let mut total = 0.0
  for index in (values.length() - 113)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 113.0
}

///|
pub fn fixed_variance_114(values : Array[Double]) -> Double {
  if values.length() < 114 {
    abort("fixed_variance_114: insufficient values")
  }
  let center = fixed_mean_114(values)
  let mut total = 0.0
  for index in (values.length() - 114)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 114.0
}

///|
pub fn fixed_variance_115(values : Array[Double]) -> Double {
  if values.length() < 115 {
    abort("fixed_variance_115: insufficient values")
  }
  let center = fixed_mean_115(values)
  let mut total = 0.0
  for index in (values.length() - 115)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 115.0
}

///|
pub fn fixed_variance_116(values : Array[Double]) -> Double {
  if values.length() < 116 {
    abort("fixed_variance_116: insufficient values")
  }
  let center = fixed_mean_116(values)
  let mut total = 0.0
  for index in (values.length() - 116)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 116.0
}

///|
pub fn fixed_variance_117(values : Array[Double]) -> Double {
  if values.length() < 117 {
    abort("fixed_variance_117: insufficient values")
  }
  let center = fixed_mean_117(values)
  let mut total = 0.0
  for index in (values.length() - 117)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 117.0
}

///|
pub fn fixed_variance_118(values : Array[Double]) -> Double {
  if values.length() < 118 {
    abort("fixed_variance_118: insufficient values")
  }
  let center = fixed_mean_118(values)
  let mut total = 0.0
  for index in (values.length() - 118)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 118.0
}

///|
pub fn fixed_variance_119(values : Array[Double]) -> Double {
  if values.length() < 119 {
    abort("fixed_variance_119: insufficient values")
  }
  let center = fixed_mean_119(values)
  let mut total = 0.0
  for index in (values.length() - 119)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 119.0
}

///|
pub fn fixed_variance_120(values : Array[Double]) -> Double {
  if values.length() < 120 {
    abort("fixed_variance_120: insufficient values")
  }
  let center = fixed_mean_120(values)
  let mut total = 0.0
  for index in (values.length() - 120)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 120.0
}

///|
pub fn fixed_variance_121(values : Array[Double]) -> Double {
  if values.length() < 121 {
    abort("fixed_variance_121: insufficient values")
  }
  let center = fixed_mean_121(values)
  let mut total = 0.0
  for index in (values.length() - 121)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 121.0
}

///|
pub fn fixed_variance_122(values : Array[Double]) -> Double {
  if values.length() < 122 {
    abort("fixed_variance_122: insufficient values")
  }
  let center = fixed_mean_122(values)
  let mut total = 0.0
  for index in (values.length() - 122)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 122.0
}

///|
pub fn fixed_variance_123(values : Array[Double]) -> Double {
  if values.length() < 123 {
    abort("fixed_variance_123: insufficient values")
  }
  let center = fixed_mean_123(values)
  let mut total = 0.0
  for index in (values.length() - 123)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 123.0
}

///|
pub fn fixed_variance_124(values : Array[Double]) -> Double {
  if values.length() < 124 {
    abort("fixed_variance_124: insufficient values")
  }
  let center = fixed_mean_124(values)
  let mut total = 0.0
  for index in (values.length() - 124)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 124.0
}

///|
pub fn fixed_variance_125(values : Array[Double]) -> Double {
  if values.length() < 125 {
    abort("fixed_variance_125: insufficient values")
  }
  let center = fixed_mean_125(values)
  let mut total = 0.0
  for index in (values.length() - 125)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 125.0
}

///|
pub fn fixed_variance_126(values : Array[Double]) -> Double {
  if values.length() < 126 {
    abort("fixed_variance_126: insufficient values")
  }
  let center = fixed_mean_126(values)
  let mut total = 0.0
  for index in (values.length() - 126)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 126.0
}

///|
pub fn fixed_variance_127(values : Array[Double]) -> Double {
  if values.length() < 127 {
    abort("fixed_variance_127: insufficient values")
  }
  let center = fixed_mean_127(values)
  let mut total = 0.0
  for index in (values.length() - 127)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 127.0
}

///|
pub fn fixed_variance_128(values : Array[Double]) -> Double {
  if values.length() < 128 {
    abort("fixed_variance_128: insufficient values")
  }
  let center = fixed_mean_128(values)
  let mut total = 0.0
  for index in (values.length() - 128)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 128.0
}

///|
pub fn fixed_variance_129(values : Array[Double]) -> Double {
  if values.length() < 129 {
    abort("fixed_variance_129: insufficient values")
  }
  let center = fixed_mean_129(values)
  let mut total = 0.0
  for index in (values.length() - 129)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 129.0
}

///|
pub fn fixed_variance_130(values : Array[Double]) -> Double {
  if values.length() < 130 {
    abort("fixed_variance_130: insufficient values")
  }
  let center = fixed_mean_130(values)
  let mut total = 0.0
  for index in (values.length() - 130)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 130.0
}

///|
pub fn fixed_variance_131(values : Array[Double]) -> Double {
  if values.length() < 131 {
    abort("fixed_variance_131: insufficient values")
  }
  let center = fixed_mean_131(values)
  let mut total = 0.0
  for index in (values.length() - 131)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 131.0
}

///|
pub fn fixed_variance_132(values : Array[Double]) -> Double {
  if values.length() < 132 {
    abort("fixed_variance_132: insufficient values")
  }
  let center = fixed_mean_132(values)
  let mut total = 0.0
  for index in (values.length() - 132)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 132.0
}

///|
pub fn fixed_variance_133(values : Array[Double]) -> Double {
  if values.length() < 133 {
    abort("fixed_variance_133: insufficient values")
  }
  let center = fixed_mean_133(values)
  let mut total = 0.0
  for index in (values.length() - 133)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 133.0
}

///|
pub fn fixed_variance_134(values : Array[Double]) -> Double {
  if values.length() < 134 {
    abort("fixed_variance_134: insufficient values")
  }
  let center = fixed_mean_134(values)
  let mut total = 0.0
  for index in (values.length() - 134)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 134.0
}

///|
pub fn fixed_variance_135(values : Array[Double]) -> Double {
  if values.length() < 135 {
    abort("fixed_variance_135: insufficient values")
  }
  let center = fixed_mean_135(values)
  let mut total = 0.0
  for index in (values.length() - 135)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 135.0
}

///|
pub fn fixed_variance_136(values : Array[Double]) -> Double {
  if values.length() < 136 {
    abort("fixed_variance_136: insufficient values")
  }
  let center = fixed_mean_136(values)
  let mut total = 0.0
  for index in (values.length() - 136)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 136.0
}

///|
pub fn fixed_variance_137(values : Array[Double]) -> Double {
  if values.length() < 137 {
    abort("fixed_variance_137: insufficient values")
  }
  let center = fixed_mean_137(values)
  let mut total = 0.0
  for index in (values.length() - 137)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 137.0
}

///|
pub fn fixed_variance_138(values : Array[Double]) -> Double {
  if values.length() < 138 {
    abort("fixed_variance_138: insufficient values")
  }
  let center = fixed_mean_138(values)
  let mut total = 0.0
  for index in (values.length() - 138)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 138.0
}

///|
pub fn fixed_variance_139(values : Array[Double]) -> Double {
  if values.length() < 139 {
    abort("fixed_variance_139: insufficient values")
  }
  let center = fixed_mean_139(values)
  let mut total = 0.0
  for index in (values.length() - 139)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 139.0
}

///|
pub fn fixed_variance_140(values : Array[Double]) -> Double {
  if values.length() < 140 {
    abort("fixed_variance_140: insufficient values")
  }
  let center = fixed_mean_140(values)
  let mut total = 0.0
  for index in (values.length() - 140)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 140.0
}

///|
pub fn fixed_variance_141(values : Array[Double]) -> Double {
  if values.length() < 141 {
    abort("fixed_variance_141: insufficient values")
  }
  let center = fixed_mean_141(values)
  let mut total = 0.0
  for index in (values.length() - 141)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 141.0
}

///|
pub fn fixed_variance_142(values : Array[Double]) -> Double {
  if values.length() < 142 {
    abort("fixed_variance_142: insufficient values")
  }
  let center = fixed_mean_142(values)
  let mut total = 0.0
  for index in (values.length() - 142)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 142.0
}

///|
pub fn fixed_variance_143(values : Array[Double]) -> Double {
  if values.length() < 143 {
    abort("fixed_variance_143: insufficient values")
  }
  let center = fixed_mean_143(values)
  let mut total = 0.0
  for index in (values.length() - 143)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 143.0
}

///|
pub fn fixed_variance_144(values : Array[Double]) -> Double {
  if values.length() < 144 {
    abort("fixed_variance_144: insufficient values")
  }
  let center = fixed_mean_144(values)
  let mut total = 0.0
  for index in (values.length() - 144)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 144.0
}

///|
pub fn fixed_variance_145(values : Array[Double]) -> Double {
  if values.length() < 145 {
    abort("fixed_variance_145: insufficient values")
  }
  let center = fixed_mean_145(values)
  let mut total = 0.0
  for index in (values.length() - 145)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 145.0
}

///|
pub fn fixed_variance_146(values : Array[Double]) -> Double {
  if values.length() < 146 {
    abort("fixed_variance_146: insufficient values")
  }
  let center = fixed_mean_146(values)
  let mut total = 0.0
  for index in (values.length() - 146)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 146.0
}

///|
pub fn fixed_variance_147(values : Array[Double]) -> Double {
  if values.length() < 147 {
    abort("fixed_variance_147: insufficient values")
  }
  let center = fixed_mean_147(values)
  let mut total = 0.0
  for index in (values.length() - 147)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 147.0
}

///|
pub fn fixed_variance_148(values : Array[Double]) -> Double {
  if values.length() < 148 {
    abort("fixed_variance_148: insufficient values")
  }
  let center = fixed_mean_148(values)
  let mut total = 0.0
  for index in (values.length() - 148)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 148.0
}

///|
pub fn fixed_variance_149(values : Array[Double]) -> Double {
  if values.length() < 149 {
    abort("fixed_variance_149: insufficient values")
  }
  let center = fixed_mean_149(values)
  let mut total = 0.0
  for index in (values.length() - 149)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 149.0
}

///|
pub fn fixed_variance_150(values : Array[Double]) -> Double {
  if values.length() < 150 {
    abort("fixed_variance_150: insufficient values")
  }
  let center = fixed_mean_150(values)
  let mut total = 0.0
  for index in (values.length() - 150)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 150.0
}

///|
pub fn fixed_variance_151(values : Array[Double]) -> Double {
  if values.length() < 151 {
    abort("fixed_variance_151: insufficient values")
  }
  let center = fixed_mean_151(values)
  let mut total = 0.0
  for index in (values.length() - 151)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 151.0
}

///|
pub fn fixed_variance_152(values : Array[Double]) -> Double {
  if values.length() < 152 {
    abort("fixed_variance_152: insufficient values")
  }
  let center = fixed_mean_152(values)
  let mut total = 0.0
  for index in (values.length() - 152)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 152.0
}

///|
pub fn fixed_variance_153(values : Array[Double]) -> Double {
  if values.length() < 153 {
    abort("fixed_variance_153: insufficient values")
  }
  let center = fixed_mean_153(values)
  let mut total = 0.0
  for index in (values.length() - 153)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 153.0
}

///|
pub fn fixed_variance_154(values : Array[Double]) -> Double {
  if values.length() < 154 {
    abort("fixed_variance_154: insufficient values")
  }
  let center = fixed_mean_154(values)
  let mut total = 0.0
  for index in (values.length() - 154)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 154.0
}

///|
pub fn fixed_variance_155(values : Array[Double]) -> Double {
  if values.length() < 155 {
    abort("fixed_variance_155: insufficient values")
  }
  let center = fixed_mean_155(values)
  let mut total = 0.0
  for index in (values.length() - 155)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 155.0
}

///|
pub fn fixed_variance_156(values : Array[Double]) -> Double {
  if values.length() < 156 {
    abort("fixed_variance_156: insufficient values")
  }
  let center = fixed_mean_156(values)
  let mut total = 0.0
  for index in (values.length() - 156)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 156.0
}

///|
pub fn fixed_variance_157(values : Array[Double]) -> Double {
  if values.length() < 157 {
    abort("fixed_variance_157: insufficient values")
  }
  let center = fixed_mean_157(values)
  let mut total = 0.0
  for index in (values.length() - 157)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 157.0
}

///|
pub fn fixed_variance_158(values : Array[Double]) -> Double {
  if values.length() < 158 {
    abort("fixed_variance_158: insufficient values")
  }
  let center = fixed_mean_158(values)
  let mut total = 0.0
  for index in (values.length() - 158)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 158.0
}

///|
pub fn fixed_variance_159(values : Array[Double]) -> Double {
  if values.length() < 159 {
    abort("fixed_variance_159: insufficient values")
  }
  let center = fixed_mean_159(values)
  let mut total = 0.0
  for index in (values.length() - 159)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 159.0
}

///|
pub fn fixed_variance_160(values : Array[Double]) -> Double {
  if values.length() < 160 {
    abort("fixed_variance_160: insufficient values")
  }
  let center = fixed_mean_160(values)
  let mut total = 0.0
  for index in (values.length() - 160)..<values.length() {
    let delta = values[index] - center
    total = total + delta * delta
  }
  total / 160.0
}
