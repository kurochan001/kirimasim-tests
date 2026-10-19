/*
:name: test_incdec_wide_vector
:description: Increment and decrement of vectors wider than 64 bits, and of a vector with an x bit (IEEE 1800-2023 Section 11.4.2)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.2 11.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_incdec_wide_vector.expected
*/
// IEEE 1800-2023 §11.4.2: ++ and -- add or subtract one at the full width of the
// operand, so a vector wider than 64 bits carries into and wraps at its top bit.
// As a statement or in an expression, x++ gives the old value and ++x the new
// one. Like the other arithmetic operators (11.4.3), an x or z bit in the operand
// makes every bit of the result x.

module test_incdec_wide_vector;
  logic [64:0] a, b, c, d, e, t1, t2;
  logic [128:0] wv;
  logic [7:0] xv, n8;
  logic signed [7:0] s8;
  logic [63:0] n64;
  int errors = 0;

  task automatic check(string what, logic [128:0] got, logic [128:0] exp);
    if (got !== exp) begin
      $display("WRONG %s = %h, expected %h", what, got, exp);
      errors++;
    end
  endtask

  initial begin
    a = 65'h1_0000_0000_0000_0003; b = a; c = a; d = a;
    a++; check("A a++ (65 bits)", a, 65'h1_0000_0000_0000_0004);
    ++b; check("B ++b (65 bits)", b, 65'h1_0000_0000_0000_0004);
    c--; check("C c-- (65 bits)", c, 65'h1_0000_0000_0000_0002);
    --d; check("D --d (65 bits)", d, 65'h1_0000_0000_0000_0002);
    e = 65'h3; e++; check("E small value in 65 bits", e, 65'h4);
    e = '1; e++; check("F all ones wraps (65 bits)", e, 65'h0);
    e = 65'h0_FFFF_FFFF_FFFF_FFFF; e++; check("G carry into bit 64", e, 65'h1_0000_0000_0000_0000);
    wv = {1'b1, 128'h3}; wv++; check("H 129 bits", wv, {1'b1, 128'h4});
    e = 65'h1_0000_0000_0000_0005;
    t1 = e++; check("I post-increment value", t1, 65'h1_0000_0000_0000_0005);
    t2 = ++e; check("J pre-increment value", t2, 65'h1_0000_0000_0000_0007);
    xv = 8'b0000_x001; xv++; check("K x bit gives x", xv, 8'bxxxx_xxxx);
    // Controls at 64 bits and below
    n8 = 8'hFF; n8++; check("ctl 8-bit wrap", n8, 8'h00);
    s8 = -128; s8--; check("ctl signed 8-bit wrap", s8, 8'sd127);
    n64 = '1; n64++; check("ctl 64-bit wrap", n64, 64'h0);
    if (errors == 0) begin
      $display("TEST PASSED: wide increment and decrement keep the full width");
    end else begin
      $display("TEST FAILED: %0d errors", errors);
    end
    $finish;
  end
endmodule
