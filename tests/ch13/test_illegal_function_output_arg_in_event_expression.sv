/*
:name: test_illegal_function_output_arg_in_event_expression
:description: a function with an output formal cannot be called in an event expression, while one with only a const ref formal can (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the event control of the second initial procedure calls value_and_copy, which has the output formal y
:expected_stderr_regex: test_illegal_function_output_arg_in_event_expression\.sv:40:
*/
// IEEE 1800-2023 13.4: it shall be illegal to call a function with output,
// inout or ref formals in an event expression; a const ref formal is
// allowed there. value_only has a single const ref formal, and the event
// control @(value_only(a)) is legal. value_and_copy has the output formal y,
// and @(value_and_copy(a, copy)) is illegal. Without the second initial
// procedure the design prints hits=1 at time 2: a changes at time 1, the
// value of the call changes with it and wakes the first procedure.
// Icarus Verilog 13.0 does not parse const ref formals, and the 5.054
// release of Verilator reports the legal call of value_only in the event
// control as an unsupported impure function call; neither error counts.

module test_illegal_function_output_arg_in_event_expression;
  logic [3:0] a = 4'd1;
  int copy, hits = 0;

  function int value_and_copy(input logic [3:0] x, output int y);
    y = x;
    return x;
  endfunction

  function automatic int value_only(const ref logic [3:0] x);
    return x;
  endfunction

  initial @(value_only(a)) hits = hits + 1;

  initial @(value_and_copy(a, copy)) hits = hits + 1;   // illegal: output formal

  initial begin
    #1 a = 4'd2;
    #1 $display("hits=%0d", hits);
  end
endmodule
