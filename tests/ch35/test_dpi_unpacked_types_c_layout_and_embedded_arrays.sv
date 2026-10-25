/*
:name: test_dpi_unpacked_types_c_layout_and_embedded_arrays
:description: An unpacked struct of byte, int, longint, real and shortint and sized unpacked arrays of real and byte reach C as the matching C struct and arrays, in both directions; unpacked arrays of packed elements inside a struct and as stand-alone sized formals are C arrays whose elements are canonical chunks, the lowest index first (IEEE 1800-2023 Section 35.5.6, H.7.3, H.7.8)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6 H.7.3 H.7.8 H.7.4 H.7.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_unpacked_types_c_layout_and_embedded_arrays.c
:expected_stdout: @test_dpi_unpacked_types_c_layout_and_embedded_arrays.expected
*/
// IEEE 1800-2023 H.7.3, H.7.8: a type that is not packed and has no packed
// parts has the layout the C compiler gives it, its basic members having the
// C types of H.7.4 (byte char, shortint short, int int, longint long long,
// real double). An unpacked array inside a struct has the C layout whatever
// its element type, and so has a stand-alone array passed to a sized formal;
// a packed element in such an array is in the canonical form (svLogicVecVal
// or svBitVecVal chunks, SV_PACKED_DATA_NELEMS of them), and the element with
// the lowest index comes first (H.7.6).
//
// c_basic reads the struct x and the arrays ra[0:2] and ba[3:0] as C struct
// and C arrays and fills the output struct y. c_arrays reads the struct a,
// which holds int n, logic [7:0] v [0:2] and bit [39:0] w [1:0], as a C
// struct with an svLogicVecVal array and an array of two-chunk svBitVecVal
// elements, and the stand-alone sized arrays sv [2:0] of logic [7:0] and
// sw [0:1] of bit [39:0], printing the elements in C order.
//
// Icarus Verilog 13.0 does not support unpacked structs, and Verilator 5.052
// rejects an unpacked struct as a DPI argument, so :oracle: names no
// simulator.

module test_dpi_unpacked_types_c_layout_and_embedded_arrays;
  typedef struct {
    byte b;
    int i;
    longint l;
    real r;
    shortint s;
  } basic_t;
  typedef struct {
    int n;
    logic [7:0] v [0:2];
    bit [39:0] w [1:0];
  } arr_t;

  import "DPI-C" function void c_basic(input basic_t x, output basic_t y, input real ra [0:2],
                                       input byte ba [3:0]);
  import "DPI-C" function void c_arrays(input arr_t a, input logic [7:0] sv [2:0],
                                        input bit [39:0] sw [0:1]);

  basic_t x, y;
  real ra [0:2];
  byte ba [3:0];
  arr_t a;
  logic [7:0] sv [2:0];
  bit [39:0] sw [0:1];

  initial begin
    x = '{b: -4, i: 100000, l: -64'sd7000000000, r: 3.75, s: -1234};
    ra = '{0.5, 1.5, 2.5};
    ba = '{4, 3, 2, 1};
    c_basic(x, y, ra, ba);
    $display("y: b %0d i %0d l %0d r %0.2f s %0d", y.b, y.i, y.l, y.r, y.s);
    a.n = 3;
    a.v = '{8'h11, 8'h22, 8'h33};
    a.w[1] = 40'hab_cdef_0123;
    a.w[0] = 40'h01_2345_6789;
    sv = '{8'h0c, 8'h0b, 8'h0a};
    sw = '{40'hff_0000_0001, 40'h80_ffff_ffff};
    c_arrays(a, sv, sw);
  end
endmodule
