/*
:name: test_checker_generate_instance
:description: A checker can be instantiated once for each iteration of a generate loop, and each instance drives its own output (IEEE 1800-2023 Section 17.3)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.3 17.2 17.7.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_generate_instance.expected
*/
// IEEE 1800-2023 §17.3: a checker may be instantiated in a generate block,
// where each iteration elaborates its own checker instance. §17.2: each
// instance connects its own actuals and drives its own output, so the four
// iterations of chk_and compute the four bits of c from a and b.

checker chk_and(input logic a, input logic b, output logic c);
  always_comb c = a & b;
endchecker

module test_checker_generate_instance;
  logic [3:0] a = 4'b1010;
  logic [3:0] b = 4'b1100;
  logic [3:0] c;

  genvar i;
  generate
    for (i = 0; i < 4; i++) begin : g
      chk_and u(.a(a[i]), .b(b[i]), .c(c[i]));
    end
  endgenerate

  initial #1 $display("c=%b", c);
endmodule
