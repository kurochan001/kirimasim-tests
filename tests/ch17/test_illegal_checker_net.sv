/*
:name: test_illegal_checker_net
:description: A net shall not be declared in a checker body, although checker variables and output arguments are allowed (IEEE 1800-2023 Section 17.1)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the checker body declares the net w with wire
:expected_stderr_regex: test_illegal_checker_net\.sv:21:
*/
// IEEE 1800-2023 §17.1: no nets can be declared or assigned in a checker.
// The checker below declares the variable v and drives the output y from it,
// which is legal. The declaration wire w is a net declaration inside the
// checker body and is illegal, even though w is never assigned. The module
// instantiates the checker so that its body is elaborated.

checker chk_net(input logic a, output logic y);
  wire w;                 // illegal: net in a checker body
  int v;

  always_comb begin
    v = a;
    y = v;
  end
endchecker

module test_illegal_checker_net;
  logic a = 1;
  logic y;

  chk_net c(a, y);

  initial begin
    #1 $display("y=%0d", y);
  end
endmodule
