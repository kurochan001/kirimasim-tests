/*
:name: test_vpi_systf_override_builtin
:description: A VPI application registered under the name of a built-in system function or task, $random and $stop, replaces the built-in one (IEEE 1800-2023 Section 36.3.2)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.3.2 38.37.1 20.14.1 20.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_override_builtin.c
:expected_stdout: @test_vpi_systf_override_builtin.expected
*/
// IEEE 1800-2023 §36.3.2: when a user-provided PLI application is registered
// under the name of a built-in system task or system function, the
// application replaces the built-in one. The application registers $random as
// a system function of type vpiIntFunc that returns 100, 101, 102 and so on,
// and $stop as a system task that only prints a line, so the simulation goes
// on after it (20.2).

module test_vpi_systf_override_builtin;
  integer a, b;

  initial begin
    a = $random;
    b = $random;
    $display("a = %0d, b = %0d, next = %0d", a, b, $random);
    $stop;
    $display("still running after $stop");
  end
endmodule
