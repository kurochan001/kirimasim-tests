/*
:name: test_short_circuit_counts_rhs_calls
:description: Logical short circuiting skips side effects on false and true controlling operands (IEEE 1800-2023 Section 11.3.5)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_short_circuit_counts_rhs_calls.expected
*/
// IEEE 1800-2023 11.3.5: A call counted on the right hand side runs only when
// the left operand cannot determine the result.

module test_short_circuit_counts_rhs_calls;
  int calls;
  bit result;
  function automatic bit visit(); calls++; return 1; endfunction
  initial begin
    result = 0 && visit();
    $display("and_zero=%0d calls=%0d", result, calls);
    result = 1 || visit();
    $display("or_one=%0d calls=%0d", result, calls);
    result = 1 && visit();
    $display("and_one=%0d calls=%0d", result, calls);
  end
endmodule
