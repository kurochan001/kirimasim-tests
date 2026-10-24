/*
:name: test_illegal_initial_block_variable_initializer_no_keyword
:description: In a procedural block, a variable declared with an initializer needs the keyword static or automatic (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.21 9.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable seed of an initial procedure block is declared with an initializer but without static or automatic
:expected_stderr_regex: test_illegal_initial_block_variable_initializer_no_keyword\.sv:25:
*/
// IEEE 1800-2023 §6.21: the variables of a procedural block default to a
// static lifetime, but a static variable declared with an initial value
// needs the explicit keyword static, to show that it is initialized only
// once. The variable seed of the begin-end block of the initial procedure
// (§9.2.1) could be automatic, so the keyword is required. The design
// has no other error: the loop variable i may be initialized without one.
// Icarus Verilog 13.0 gives only a warning for it, and Verilator 5.052
// accepts it.

module test_illegal_initial_block_variable_initializer_no_keyword;
  initial begin
    int seed = 7;    // illegal: initializer without static or automatic
    for (int i = 0; i < 2; i++) seed += i;
    $display("%0d", seed);
  end
endmodule
