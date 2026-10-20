/*
:name: test_fatal_from_function
:description: $fatal called inside a function ends the whole simulation with an error code, so the caller does not continue (IEEE 1800-2023 Section 20.10)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.10 13.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: nonzero
:expected_stdout: @test_fatal_from_function.expected
*/
// IEEE 1800-2023 §20.10: $fatal ends the simulation with an error code. A
// function can call it (13.4 lets functions call system tasks that do not
// consume time). checked() returns its argument while it is not negative; for
// -1 it calls $fatal, so the caller prints nothing more.

module test_fatal_from_function;
  function int checked(int v);
    if (v < 0)
      $fatal(1, "negative value %0d", v);
    return v;
  endfunction

  initial begin
    $display("got %0d", checked(4));
    $display("got %0d", checked(0));
    $display("got %0d", checked(-1));
    $display("done");
  end
endmodule
