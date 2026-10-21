/*
:name: test_dpi_wysiwyg_formal_types
:description: The C side of an import sees each argument with exactly the type and ranges of the formal in the import declaration, whatever the width, signedness or range of the actual, while the unsized dimension of an open array takes the range of the actual at each call (IEEE 1800-2023 Section 35.6.1.1)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.6.1.1 35.6.1 H.7.6 H.12.1 H.12.2 7.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_wysiwyg_formal_types.c
:expected_stdout: @test_dpi_wysiwyg_formal_types.expected
*/
// IEEE 1800-2023 §35.6.1.1: an actual argument is guaranteed to have the type
// of the formal, with the ranges that the import declaration gives; only the
// declaration matters. §35.6.1: when the actual has another type, a
// temporary of the formal's type is passed, initialized from the actual and,
// for inout, assigned back to it, by the rules of assignment. So the 4-bit,
// 32-bit and signed 8-bit actuals of c_low16 reach C as 16 bits (extended by
// the actual's signedness, or truncated), and c_add's int is assigned back to
// a byte and a 4-bit vector. The int[0:3] actual of c_ends is copied element
// by element, left to right (7.6), into the formal a[3:0], whose element 0
// is C element 0 (H.7.6), so C sees 40 first. For the open array of c_shape,
// the unpacked range is that of each actual and the packed one is the
// normalized [7:0] of the declared bit [15:8] (H.7.6, H.12.1, H.12.2).
// In Verilator 5.052, C gets the elements of up in their own order, so C
// element 0 is up[0], 10, here.

module test_dpi_wysiwyg_formal_types;
  import "DPI-C" function void c_ends(input int a[3:0], output int c0, output int c3);
  import "DPI-C" function int c_low16(input bit [15:0] v);
  import "DPI-C" function void c_add(inout int v, input int add);
  import "DPI-C" function int c_shape(input bit [15:8] b []);

  int up[0:3] = '{10, 20, 30, 40};
  bit [3:0] nibble = 4'ha;
  bit [31:0] word = 32'h1234_abcd;
  byte minus_one = -1;
  byte hundred = 100;
  bit [3:0] count = 9;
  bit [7:0] q [2:4];
  bit [7:0] r [5:3];
  int c0, c3;

  initial begin
    c_ends(up, c0, c3);
    $display("c_ends: C element 0 is %0d, C element 3 is %0d", c0, c3);
    $display("c_low16: %h %h %h", c_low16(nibble), c_low16(word), c_low16(minus_one));
    c_add(hundred, 100);
    c_add(count, 10);
    $display("c_add: byte %0d, 4-bit %0d", hundred, count);
    $display("c_shape: %0d and %0d", c_shape(q), c_shape(r));
  end
endmodule
