/*
:name: test_illegal_randsequence_void_production_value
:description: a production declared without a return type is void, so no variable is declared for it in a rule that generates it, and a code block that reads its name as a value is an error (IEEE 1800-2023 Section 18.17.7)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.17.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the code block after mark in the rule of main reads mark as a value, but mark has no return type, so no variable named mark is declared in that rule
:expected_stderr_regex: test_illegal_randsequence_void_production_value\.sv:33:
*/
// IEEE 1800-2023 §18.17.7: a production that does not specify a return type
// has the void return type. Within a rule, a variable is implicitly declared
// only for each production of the rule that returns a value, and a code block
// of the rule reads the value returned by such a production through the
// production name.
// In the rule of main, num returns int, so the code block after it may read
// num. mark is declared without a return type, so the rule has no variable
// mark, and the code block after mark that reads it is the only error. No
// other variable is named mark.
// Icarus Verilog 13.0 does not support randsequence, and the 5.054 release
// of Verilator does not support productions that return a value and rejects
// the legal read of num as well, so neither error counts.

module test_illegal_randsequence_void_production_value;
  int got;

  initial begin
    randsequence (main)
      main : num { got = num; }
             mark { got = got + mark; };   // illegal
      int num : { return 5; };
      mark : { got = 0; };
    endsequence
    $display("got=%0d", got);
  end
endmodule
