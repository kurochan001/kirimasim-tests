/*
:name: test_illegal_pathpulse_output_part_select
:description: The output terminal of a path-specific PATHPULSE$ specparam cannot be a part-select of a vector, while the entire vector port is legal (IEEE 1800-2023 Section 30.7.1)
:tags: ch30
:type: elaboration
:lrm: 1800-2023 30.7.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the PATHPULSE$ specparam for the path from c to w names the part-select w[1:0] as its output terminal
:expected_stderr_regex: test_illegal_pathpulse_output_part_select\.sv:26:
*/
// IEEE 1800-2023 §30.7.1: the terminals named in a path-specific PATHPULSE$
// specparam shall not be a bit-select or part-select of a vector. The
// specparam for the path from a to v names the vector port v, which is
// legal. The one for the path from c to w names the part-select w[1:0].

module ppo_cell(input wire a, input wire c, output wire [1:0] v, output wire [1:0] w);
  assign v = {a, a};
  assign w = {c, c};
  specify
    (a *> v) = 4;
    (c *> w) = 4;
    specparam PATHPULSE$a$v = (1, 2);
    specparam PATHPULSE$c$w[1:0] = (1, 2);   // illegal: part-select as the output terminal
  endspecify
endmodule

module test_illegal_pathpulse_output_part_select;
  logic a = 1'b1, c = 1'b0;
  wire [1:0] v, w;
  ppo_cell u (.a(a), .c(c), .v(v), .w(w));
  initial #10 $display("%b %b", v, w);
endmodule
