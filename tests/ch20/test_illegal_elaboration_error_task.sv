/*
:name: test_illegal_elaboration_error_task
:description: An elaboration-time $error that remains after generate expansion is executed and keeps the simulation from starting (IEEE 1800-2023 Section 20.10.1)
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.10.1 20.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the generate condition holds, so the elaboration $error runs
:expected_stderr_regex: test_illegal_elaboration_error_task\.sv:22:
*/
// IEEE 1800-2023 §20.10.1: an elaboration severity task called outside
// procedures runs when it remains after generate expansion; for $error
// elaboration goes on but the simulation is not started. The message shall name
// the file and line of the call. W is 4, so the branch with the $error is
// generated.

module test_illegal_elaboration_error_task #(parameter int W = 4);
  if (W < 8) begin : narrow
    $error("W is too narrow");   // illegal: an elaboration error
  end
  initial $display("the simulation must not start");
endmodule
