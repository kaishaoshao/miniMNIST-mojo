from sys import simdwidthof
from algorithm.functional import vectorize

alias simd_width = simdwidthof[DType.float32]()

var a: UnsafePointer[Float32] = UnsafePointer[Float32].alloc(10)
var b: UnsafePointer[Float32] = UnsafePointer[Float32].alloc(10)


fn main():
  for i in range(0, 10):
    a.offset(i).store[width=1](i)
  @parameter
  fn _load[simd_width: Int](i: Int):
    b.offset(i).store[width=simd_width](a.offset(i).load[width=simd_width]())
  vectorize[_load, simd_width, unroll_factor=simd_width](10)
  for i in range(0, 10, simd_width):
    print(b.offset(i).load[width=simd_width]())
