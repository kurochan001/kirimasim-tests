/*
:name: test_short_circuit_suppresses_fatal_operand
:description: Skip operands whose evaluation would produce a visible side effect and fatal error
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.5 11.4.7 11.4.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_short_circuit_suppresses_fatal_operand.expected
*/
// IEEE 11.3.5: skipped operand evaluation must produce neither side
// effects nor run-time errors. Each forbidden operand would increment a
// counter and execute $fatal if evaluated. Surviving all five expressions
// with calls=0 checks both effects; no illegal syntax or bad handle is used.
// Icarus 13.0 evaluates a forbidden operand and terminates at $fatal.
module test_short_circuit_suppresses_fatal_operand;
  int calls = 0;
  bit zero = 0, one = 1;
  function automatic bit forbidden();
    calls++;
    $fatal(1, "ERROR: a short-circuited operand was evaluated");
    return 1;
  endfunction
  initial begin
    $display("logical=%0d %0d %0d",
             zero && forbidden(), one || forbidden(), zero -> forbidden());
    $display("branches=%0d %0d", one ? 7 : forbidden(), zero ? forbidden() : 9);
    $display("calls=%0d survived", calls);
    $finish;
  end
endmodule
