/*
:name: test_forward_function_in_enclosing_scope
:description: A function call in an inner named block resolves a later function in its enclosing module (IEEE 1800-2023 Section 13.7)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.7
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_forward_function_in_enclosing_scope.expected
*/
// IEEE 1800-2023 13.7: Subroutine name lookup permits this forward reference
// without a prior prototype and finds the enclosing scope definition.

module test_forward_function_in_enclosing_scope;
  initial begin : caller
    $display("forward=%0d", later(6));
  end
  function automatic int later(int n); return n * 3; endfunction
endmodule
