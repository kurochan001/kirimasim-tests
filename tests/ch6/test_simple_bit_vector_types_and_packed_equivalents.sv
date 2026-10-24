/*
:name: test_simple_bit_vector_types_and_packed_equivalents
:description: The integer types with predefined widths are one-dimensional packed bit vectors [n-1:0]; packed structures, packed unions and multidimensional packed arrays are not, but each is equivalent to a simple bit vector type of the same width, state and signing, so it can be passed to a ref argument of that type and converted to and from it (IEEE 1800-2023 Section 6.11.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11.1 6.22.2 7.4.1 20.7 13.5.2
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_simple_bit_vector_types_and_packed_equivalents.expected
*/
// IEEE 1800-2023 §6.11.1: a simple bit vector type directly represents a
// one-dimensional packed array of bits, and the integer types of Table 6-8
// are such types with predefined widths: byte, shortint, int, longint,
// integer and time act as a packed array with the single dimension [n-1:0]
// (7.4.1, 20.7). Each variable below holds a value whose top nibble is a
// and whose bit 0 is 1: $left is n-1, $right is 0, $dimensions is 1, the
// part-select [n-1 -: 4] is a and bit [0] is 1. A logic [5:0] vector
// (another simple bit vector type) has $left 5.
// Packed structures, packed unions and multidimensional packed arrays are not
// simple bit vector types, but each is equivalent (6.22.2) to one: a packed
// structure or union is a nonarray type with $dimensions 1 (20.7), while
// the two-dimensional packed array pa has $dimensions 2, and pa[1] is its
// element 4'h5, not a bit as bv[1] of the simple bit vector bv is.
// Equivalence: a ref argument takes only an actual of an equivalent type
// (13.5.2). The 8-bit 2-state unsigned structure ns, union un and array pa
// are passed to ref bit [7:0], which adds 8'h11 to each; the 8-bit 2-state
// signed structure sv to ref byte, which negates it (5 becomes -5, 8'hfb, so
// tag is 11 and val is 3b); and m8, whose member b is logic and which is
// therefore 4-state as a whole, to ref logic [7:0], which writes z10x into
// its low bits. Conversion: ns is copied to a bit [7:0] and back into another
// structure of its type.

module test_simple_bit_vector_types_and_packed_equivalents;
  typedef struct packed { bit [3:0] hi; bit [3:0] lo; } nib2_t;
  typedef union packed { bit [7:0] whole; bit [1:0][3:0] half; } u8_t;
  typedef struct packed signed { bit [1:0] tag; bit [5:0] val; } s8_t;
  typedef struct packed { bit [3:0] a; logic [3:0] b; } m8_t;

  byte by = 8'ha1;
  shortint sh = 16'ha001;
  int in = 32'ha000_0001;
  longint lg = 64'ha000_0000_0000_0001;
  integer ig = 32'ha000_0001;
  time tm = 64'ha000_0000_0000_0001;
  logic [5:0] lv = 6'b10_1001;

  nib2_t ns = 8'h12;
  u8_t un = 8'h34;
  bit [1:0][3:0] pa = 8'h56;
  bit [7:0] bv = 8'h56;
  s8_t sv = 8'sh05;
  m8_t m8 = 8'h91;
  bit [7:0] flat;
  nib2_t back;

  task automatic add11(ref bit [7:0] x);
    x = x + 8'h11;
  endtask

  task automatic negate(ref byte x);
    x = -x;
  endtask

  task automatic low_z10x(ref logic [7:0] x);
    x[3:0] = 4'bz10x;
  endtask

  initial begin
    $display("byte: %0d %0d %0d top=%h b0=%b", $left(by), $right(by), $dimensions(by),
             by[7 -: 4], by[0]);
    $display("shortint: %0d %0d %0d top=%h b0=%b", $left(sh), $right(sh), $dimensions(sh),
             sh[15 -: 4], sh[0]);
    $display("int: %0d %0d %0d top=%h b0=%b", $left(in), $right(in), $dimensions(in),
             in[31 -: 4], in[0]);
    $display("longint: %0d %0d %0d top=%h b0=%b", $left(lg), $right(lg), $dimensions(lg),
             lg[63 -: 4], lg[0]);
    $display("integer: %0d %0d %0d top=%h b0=%b", $left(ig), $right(ig), $dimensions(ig),
             ig[31 -: 4], ig[0]);
    $display("time: %0d %0d %0d top=%h b0=%b", $left(tm), $right(tm), $dimensions(tm),
             tm[63 -: 4], tm[0]);
    $display("logic [5:0]: %0d %0d %0d top=%b b0=%b", $left(lv), $right(lv), $dimensions(lv),
             lv[5 -: 4], lv[0]);
    $display("dimensions: struct %0d union %0d 2-d array %0d vector %0d",
             $dimensions(ns), $dimensions(un), $dimensions(pa), $dimensions(bv));
    $display("select [1]: 2-d array %h vector %b", pa[1], bv[1]);
    add11(ns);
    add11(un);
    add11(pa);
    negate(sv);
    low_z10x(m8);
    $display("ref bit [7:0]: ns.hi=%h ns.lo=%h un.half[1]=%h un.whole=%h pa=%h",
             ns.hi, ns.lo, un.half[1], un.whole, pa);
    $display("ref byte: sv=%0d tag=%b val=%h", sv, sv.tag, sv.val);
    $display("ref logic [7:0]: m8.a=%h m8.b=%b", m8.a, m8.b);
    flat = ns;
    back = flat;
    $display("convert: flat=%h back.hi=%h back.lo=%h", flat, back.hi, back.lo);
  end
endmodule
