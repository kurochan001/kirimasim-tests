/*
:name: test_fatal_finish_number_zero
:description: $fatal with a finish number of 0, which only lowers the diagnostics, still ends the run with an error code (IEEE 1800-2023 Section 20.10)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.10 20.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: nonzero
:expected_stdout: @test_fatal_finish_number_zero.expected
*/
// IEEE 1800-2023 §20.10: the first argument of $fatal is a finish number like
// the argument of $finish (20.2), which only says how much diagnostic
// information the tool prints. With 0 the run still ends with an error code,
// after the values printed before the call.

module test_fatal_finish_number_zero;
  int count = 0;

  initial begin
    repeat (3) begin
      count++;
      $display("count=%0d", count);
    end
    $fatal(0, "count reached %0d", count);
    $display("not reached");
  end
endmodule
