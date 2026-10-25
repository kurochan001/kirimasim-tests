/*
:name: test_dpi_open_array_whole_ptr_elem_repr
:description: For open arrays of int, real and byte, svGetArrayPtr and svSizeOfArray are either NULL and 0 or the address of the elements in C layout and their total size, and every element has an address; for packed and scalar bit and logic elements, an element address is either NULL or points to the representation of an individual value (IEEE 1800-2023 Section 35.5.6.1, H.12.4)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6.1 H.12.4 H.7.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:dpi_c: @test_dpi_open_array_whole_ptr_elem_repr.c
:expected_stdout: @test_dpi_open_array_whole_ptr_elem_repr.expected
*/
// IEEE 1800-2023 H.12.4: when the actual of an open array formal is not laid
// out as C would lay it out, the address and the size of the whole array are
// 0 (svGetArrayPtr returns NULL and svSizeOfArray 0); otherwise
// svGetArrayPtr gives the address of the array and svSizeOfArray the number
// of bytes of all its elements. The address of each element is always given,
// except that for elements of a scalar or packed type the element functions
// return NULL when such an element is not represented as an individual value
// of its type is: svBit or svLogic for a scalar, the canonical svBitVecVal or
// svLogicVecVal chunks of H.7.7 for a packed type (H.7.3).
//
// c_whole checks, for a[6:3], m[1:0][2:4] of int, r[0:2] of real and b[1:5]
// of byte, that the whole-array pointer is NULL with size 0, or else that the
// size is the number of elements times the size of the C type and that each
// element, taken in C order (the lowest index first in each dimension,
// H.7.3), is at its place from that pointer; and that every element has an
// address through which its value is read. c_repr checks, for each element of
// p[2:0] of bit [7:0], q[1:2] of logic [11:0] with x and z bits, s[0:3] of
// bit, l[0:3] of logic holding 0, 1, z and x and w[0:1] of bit [39:0], that
// its address is NULL or points to that representation of its value. Each
// check prints 1 when it holds, whichever of the permitted cases the
// implementation takes.
//
// Icarus Verilog 13.0 has no DPI. Verilator 5.052 has no x and z; for the
// real array it gives a whole-array pointer with the size 0 and the same
// address for every element. :oracle: names no simulator.

module test_dpi_open_array_whole_ptr_elem_repr;
  import "DPI-C" function void c_whole(input int a [], input int m [][], input real r [],
                                       input byte b []);
  import "DPI-C" function void c_repr(input bit [7:0] p [], input logic [11:0] q [],
                                      input bit s [], input logic l [], input bit [39:0] w []);

  int a [6:3];
  int m [1:0][2:4];
  real r [0:2];
  byte b [1:5];
  bit [7:0] p [2:0];
  logic [11:0] q [1:2];
  bit s [0:3];
  logic l [0:3];
  bit [39:0] w [0:1];

  initial begin
    foreach (a[i]) a[i] = i * 11;
    foreach (m[i, j]) m[i][j] = i * 10 + j;
    foreach (r[i]) r[i] = i + 0.25;
    foreach (b[i]) b[i] = byte'(-i);
    p = '{8'hc2, 8'h81, 8'h40};
    q = '{12'b1010_xxzz_0101, 12'hz0x};
    s = '{1'b1, 1'b0, 1'b0, 1'b1};
    l = '{1'b0, 1'b1, 1'bz, 1'bx};
    w = '{40'h12_3456_789a, 40'hfe_dcba_9876};
    c_whole(a, m, r, b);
    c_repr(p, q, s, l, w);
  end
endmodule
