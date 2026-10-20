/*
:name: test_elaboration_severity_not_generated
:description: An elaboration severity task in a generate branch that is not selected is not executed, so the simulation starts, while one called in a procedure is a run-time task (IEEE 1800-2023 Section 20.10.1)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.10.1 20.10 27.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_elaboration_severity_not_generated.expected
*/
// IEEE 1800-2023 §20.10.1: elaboration severity tasks are called outside
// procedures, and conditional generate constructs (27.5) control whether they
// remain in the elaborated model; only those that remain are executed, and
// an $error or $fatal there keeps the simulation from starting. With W = 4 the
// $error branch is not generated, so the simulation starts. The $info in the
// initial procedure is a run-time task, so it does not stop anything either;
// its message is not part of the output that the test compares.

module test_elaboration_severity_not_generated #(parameter int W = 4);
  if (W > 8) begin : too_wide
    $error("W=%0d is too wide", W);
  end

  initial begin
    $info("running with W=%0d", W);
    $display("simulation started with W=%0d", W);
  end
endmodule
