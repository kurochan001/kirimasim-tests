/*
:name: test_constant_function_ignores_display
:description: $display in a function is ignored when the function is called in a constant expression and runs when it is called during simulation (IEEE 1800-2023 Section 13.4.3)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constant_function_ignores_display.expected
*/
// IEEE 1800-2023 §13.4.3: when a function is called as part of a constant
// expression, the system tasks it calls are ignored, apart from the
// elaboration severity tasks (20.10.1). Here the same function sets a
// localparam and a parameter, which prints nothing, and is then called
// during simulation, where its $display runs as usual.

module test_constant_function_ignores_display;
  function automatic int next(input int v);
    $display("next(%0d) called", v);
    return v + 1;
  endfunction

  localparam int LP = next(0);
  parameter int P = next(LP) * 2;
  int r;

  initial begin
    r = next(10);
    $display("LP=%0d P=%0d r=%0d", LP, P, r);
  end
endmodule
