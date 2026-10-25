/*
:name: test_illegal_checker_generate_plain_always
:description: A generate item of a checker cannot contain a plain always procedure, which is illegal in a checker outside a generate item (IEEE 1800-2023 Section 17.2)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.2 17.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a plain always procedure appears in a generate block of a checker
:expected_stderr_regex: test_illegal_checker_generate_plain_always\.sv:28:
*/
// IEEE 1800-2023 17.2: it shall be illegal for a checker generate item to
// include any item that would be illegal in the checker declaration outside a
// generate item. §17.5 allows only always_comb, always_latch and always_ff in a
// checker, so the plain always procedure inside the generate block below is
// illegal there as well. The rest of the design is legal.
// The 5.052 release supports the unit-level checker but accepts the plain
// always procedure in its generate block, and Icarus Verilog 13.0 does not
// support checkers at all, so neither release produces the expected result.

`timescale 1ns/1ns

checker gen_plain(input logic clk, input logic a, output logic y);
  generate
    if (1) begin : g
      always @(posedge clk) y <= a;   // illegal
    end
  endgenerate
endchecker : gen_plain

module test_illegal_checker_generate_plain_always;
  logic clk = 1'b0, a = 1'b1;
  logic y;

  gen_plain u(.clk(clk), .a(a), .y(y));

  initial #1 clk = 1'b1;
endmodule
