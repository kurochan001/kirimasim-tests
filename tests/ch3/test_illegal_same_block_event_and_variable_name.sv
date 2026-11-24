/*
:name: test_illegal_same_block_event_and_variable_name
:description: A named block rejects an event and a variable declared with the same name
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.13
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the event and variable redeclare token in the same named block
:expected_stderr_regex: (?i)test_illegal_same_block_event_and_variable_name\.sv:22:(?=[^\n]*\btoken\b)[^\n]*(?:redecl|redefin|duplicate|already|conflict)
*/
module test_illegal_same_block_event_and_variable_name;
  initial begin : control_scope
    event token;
    -> token;
  end

  initial begin : conflicting_scope
    event token;
    int token;
  end
endmodule
