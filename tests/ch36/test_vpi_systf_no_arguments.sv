/*
:name: test_vpi_systf_no_arguments
:description: A user-defined system task or function called without arguments has no argument iterator (vpi_iterate returns NULL), and a system function without arguments can be called without parentheses (IEEE 1800-2023 Section 36.4)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.4 38.23 37.42 36.8.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_no_arguments.c
:expected_stdout: @test_vpi_systf_no_arguments.expected
*/
// IEEE 1800-2023 §36.4: the PLI application reads the arguments of a
// user-defined system task or function through VPI; §38.23: vpi_iterate
// returns NULL when there are no objects of the type asked for, so a call
// without arguments gives no vpiArgument iterator (37.42). $vt_count prints
// how many arguments it got, and $vt_next, a system function without
// arguments, returns 1, 2, 3 at its successive calls (36.8.3).

module test_vpi_systf_no_arguments;
  int a, b, c;

  initial begin
    $vt_count;
    $vt_count(7);
    $vt_count(a, b, 3);
    a = $vt_next;
    b = $vt_next + 10;
    c = $vt_next;
    $display("a=%0d b=%0d c=%0d", a, b, c);
  end
endmodule
