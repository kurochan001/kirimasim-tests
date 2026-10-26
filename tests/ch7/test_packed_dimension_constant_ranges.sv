/*
:name: test_packed_dimension_constant_ranges
:description: A packed dimension is a bracketed constant range whose bounds may be literals, localparams or constant expressions, may ascend or descend and may be negative, and each dimension is its own index space (IEEE 1800-2023 Section 7.4.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.1 A.2.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_dimension_constant_ranges.expected
*/
// IEEE 1800-2023 §7.4.1: each packed dimension of a packed array is written
// as [constant_expression : constant_expression]; the first value may be
// greater, equal or less than the second, the values may be negative, and the
// dimension contributes its width to the array. A.2.5 writes the same packed
// dimension as [constant_range] and permits the unsized_dimension only where
// A.10 clarification 24 allows it, as the sole packed dimension of a DPI
// import declaration. This test uses the constant-range alternative: the
// ranges [MSB:LSB], [0:MSB], [-1:-4], [1:0][3:0], [2+1:0] and [3:0][1:0]
// show a descending range, an ascending range, a negative range, two packed
// dimensions, a computed bound and the other order of two dimensions. The
// value 4'b1010 stored in each shows that a descending range numbers its
// left bound the most significant bit while an ascending range numbers its
// right bound the most significant bit, and $bits gives each width. No
// simulator accepts the unsized packed dimension of a DPI import, so the
// test does not use it.

module test_packed_dimension_constant_ranges;
  localparam int MSB = 3, LSB = 0;
  logic [MSB:LSB] a;
  logic [0:MSB] b;
  logic [-1:-4] c;
  logic [1:0][3:0] d;
  logic [1+1:0] e;
  logic [3:0][1:0] f;
  bit [0:0] g;

  initial begin
    a = 4'b1010;
    b = a;
    c = a;
    d = {a, 4'b0101};
    e = a;
    f = {a, 4'b0101};
    g = 1'b1;
    $display("a=%b bits=%0d a[0]=%b a[3]=%b", a, $bits(a), a[0], a[3]);
    $display("b=%b bits=%0d b[0]=%b b[3]=%b", b, $bits(b), b[0], b[3]);
    $display("c=%b bits=%0d c[-1]=%b c[-4]=%b", c, $bits(c), c[-1], c[-4]);
    $display("d=%b bits=%0d d[1]=%b d[0]=%b", d, $bits(d), d[1], d[0]);
    $display("e=%b bits=%0d", e, $bits(e));
    $display("f=%b bits=%0d f[3]=%b f[0]=%b", f, $bits(f), f[3], f[0]);
    $display("g=%b bits=%0d", g, $bits(g));
  end
endmodule
