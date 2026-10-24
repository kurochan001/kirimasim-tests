/*
:name: test_vector_select_declared_bounds_direction_and_invalid
:description: a select index names a bit by the declared bounds of the vector, +: and -: go up and down from the base in index numbers, a bit-select index is self-determined, and an invalid bit-select or part-select reads x (0 for 2-state) and a wholly invalid part-select write changes nothing (IEEE 1800-2023 Section 11.5.1)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_vector_select_declared_bounds_direction_and_invalid.expected
*/
// IEEE 1800-2023 §11.5.1: the bit that an index selects depends on the
// declared range of the vector, not on a position counted from 0. [b +: w]
// selects w bits from b upward in index numbers and [b -: w] from b
// downward; which end is more significant follows the declaration. The
// index of a bit-select, and the base of an indexed part-select, are
// self-determined. A bit-select whose index is out of bounds or has x or z
// bits reads x from a 4-state value and 0 from a 2-state one. A part-select
// wholly out of bounds, or with an x or z base, reads x and a write to it
// changes nothing; one partly out of bounds reads x for the bits outside and
// writes only the bits inside.
// up is [2:9] and dn is [15:8]: up[2] is the leftmost bit, dn[8] the
// rightmost. For d [15:0] and u [0:15] holding a5c3, [2 +: 3] is d[4:2] and
// u[2:4], [2 -: 3] is d[2:0] and u[0:2]. The 2-bit sum a2 + b2 = 3 + 1 wraps
// to 0 in its own width, so v[a2 + b2] is bit 0, not bit 4. All invalid
// indices are variables, so the selects are checked when they run.
// Icarus Verilog 13.0 reads x from invalid selects of the 2-state bit [7:0]
// b, and Verilator 5.052 has no x value.

module test_vector_select_declared_bounds_direction_and_invalid;
  logic [2:9] up = 8'b1000_0001;
  logic [15:8] dn = 8'b0000_0001;
  logic [15:0] d = 16'ha5c3;
  logic [0:15] u = 16'ha5c3;
  logic [7:0] v = 8'b0001_0000;
  logic [1:0] a2 = 2'd3, b2 = 2'd1;
  logic [7:0] l = 8'b1010_0110;
  bit [7:0] b = 8'b1010_0110;
  int i8 = 8, i9 = 9, i6 = 6, n = 2;
  logic [3:0] ix = 4'bx, iz = 4'bz;
  logic [3:0] r4;
  bit [3:0] q4;

  initial begin
    $display("declared bounds: %b %b %b %b", up[2], up[9], dn[8], dn[15]);
    $display("indexed: %b %b %b %b", d[n +: 3], u[n +: 3], d[n -: 3], u[n -: 3]);
    $display("self-determined index: %b %b", v[a2 + b2], v[a2 + b2 + 3'd0]);
    $display("invalid bit, 4-state: %b %b %b", l[i8], l[ix], l[iz]);
    $display("invalid bit, 2-state: %b %b", b[i8], b[ix]);
    r4 = l[i9 +: 4];
    q4 = b[i9 +: 4];
    $display("wholly out part-select: %b %b", r4, q4);
    r4 = l[ix +: 4];
    $display("x base part-select: %b", r4);
    r4 = l[i6 +: 4];
    $display("partly out part-select: %b", r4);
    l[i9 +: 2] = 2'b01;
    l[ix +: 2] = 2'b01;
    $display("after invalid writes: %b", l);
    l[i6 +: 4] = 4'b0101;
    $display("after partly out write: %b", l);
  end
endmodule
