/*
:name: test_fatal_ends_with_error_code
:description: $fatal ends the simulation at once with an error code; nothing after it in the same procedure or later in time runs (IEEE 1800-2023 Section 20.10)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.10 20.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: nonzero
:expected_stdout: @test_fatal_ends_with_error_code.expected
*/
// IEEE 1800-2023 §20.10: $fatal reports a run-time fatal error and ends the
// simulation with an error code; it calls $finish implicitly (20.2). The
// statement after it is not executed, and the procedure that would print at
// time 5 never gets there. The standard does not fix the value of the error
// code, only that there is one, so the test asks for a nonzero exit code. The
// message of $fatal itself has a tool-specific form and is not compared.

module test_fatal_ends_with_error_code;
  initial begin
    $display("before");
    $fatal(1, "stopping here");
    $display("after");
  end

  initial #5 $display("later");
endmodule
