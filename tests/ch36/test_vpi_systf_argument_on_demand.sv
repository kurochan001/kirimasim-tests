/*
:name: test_vpi_systf_argument_on_demand
:description: An argument of a user-defined system task is evaluated only when the application asks for its value, so a function call in an argument the application never reads does not run (IEEE 1800-2023 Section 37.42)
:tags: ch36
:type: simulation
:lrm: 1800-2023 37.42 36.4 38.15
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_argument_on_demand.c
:expected_stdout: @test_vpi_systf_argument_on_demand.expected
*/
// IEEE 1800-2023 §37.42: if no application asks for the value of an argument
// of a system task call, the argument is never evaluated; §36.4: the
// application reads arguments through VPI, with vpi_get_value (38.15). The
// argument here is a call of bump(), which counts its calls. $vt_ignore never
// reads its argument, so bump() does not run; $vt_read reads it once, so
// bump() runs once and returns 1.

module test_vpi_systf_argument_on_demand;
  int calls = 0;

  function automatic int bump();
    calls++;
    return calls;
  endfunction

  initial begin
    $vt_ignore(bump());
    $display("after $vt_ignore: calls=%0d", calls);
    $vt_read(bump());
    $display("after $vt_read: calls=%0d", calls);
  end
endmodule
