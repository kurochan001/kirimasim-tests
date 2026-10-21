/*
:name: test_vpi_systf_override_display
:description: A VPI application registered under the name of a built-in display task of Clause 21, $display or $write, replaces it, and receives the arguments of the calls unformatted, while the built-in tasks it does not register stay as they are (IEEE 1800-2023 Section 36.3.2)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.3.2 38.37.1 21.2.1 21.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_override_display.c
:expected_stdout: @test_vpi_systf_override_display.expected
*/
// IEEE 1800-2023 §36.3.2: the built-in system tasks of Clause 20 and Clause
// 21 have names that start with $, as user-defined ones do, and a PLI
// application registered under the name of a built-in one replaces its
// functionality. The application registers $display and $write (21.2.1),
// whose calls then only reach it: it prints the number of arguments and each
// one, a string literal in quotes and anything else as an integer, with no
// formatting. $strobe (21.2.2), which it does not register, still formats
// its arguments and prints them at the end of the time step.

module test_vpi_systf_override_display;
  int a = 5;

  initial begin
    $display("a is %0d", a);
    $write(a, a + 1);
    $strobe("$strobe is the built-in one: a = %0d", a);
  end
endmodule
