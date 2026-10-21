/*
:name: test_vpi_systf_function_in_expressions
:description: A user-defined system function can be called wherever a function can, inside a function, as an argument of another call, in a condition and in a loop bound (IEEE 1800-2023 Section 36.5)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.5 13.4 38.37.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_function_in_expressions.c
:expected_stdout: @test_vpi_systf_function_in_expressions.expected
*/
// IEEE 1800-2023 §36.5: a user-defined system function can be used in the same
// places as a SystemVerilog function (13.4). $vt_twice, registered as a
// vpiIntFunc (38.37.1), returns twice its argument. It is called in the body
// of a function, as the argument of another call, in the condition of an if
// statement and as the bound of a for loop.

module test_vpi_systf_function_in_expressions;
  int a = 3;
  int n;

  function automatic int times_twenty(int x);
    return $vt_twice(x) * 10;
  endfunction

  initial begin
    $display("in a function: %0d", times_twenty(2));
    $display("nested: %0d", $vt_twice($vt_twice(1)));
    if ($vt_twice(a) == 6) $display("condition: true");
    n = 0;
    for (int i = 0; i < $vt_twice(a); i++) n++;
    $display("loop bound: %0d iterations", n);
  end
endmodule
