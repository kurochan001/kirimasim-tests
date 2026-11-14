/*
:name: test_illegal_writable_formal_function_in_event_control
:description: A function with a ref formal argument that is not const cannot be called in an event expression (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the event control @(peek_ref(a)) calls peek_ref, whose formal argument x is a ref argument that is not const
:expected_stderr_regex: test_illegal_writable_formal_function_in_event_control\.sv:43:
*/
// IEEE 1800-2023 §13.4: it shall be illegal to call a function with output,
// inout or ref formal arguments in an event expression. peek_in has an input
// formal, and the event control @(peek_in(a)) is legal; peek_ref has a ref
// formal that is not const, and the event control @(peek_ref(a)) is illegal,
// although the function only reads x. Without the second event control the
// design prints hits=1: a changes at time 1, the value of peek_in(a) changes
// with it and wakes the first procedure.
// test_illegal_writable_formal_function_in_force and
// test_illegal_writable_formal_function_in_continuous_assign check the other
// two places.
// Icarus Verilog 13.0 rejects the declaration of peek_ref, since it takes
// only input formals in functions, and the 5.054 release of Verilator
// reports the marked call as an unsupported impure function call in a
// sensitivity list; neither error counts.

module test_illegal_writable_formal_function_in_event_control;
  int a = 1;
  int hits = 0;

  function int peek_in(input int x);
    return x;
  endfunction

  function automatic int peek_ref(ref int x);
    return x;
  endfunction

  initial @(peek_in(a)) hits = hits + 1;

  initial @(peek_ref(a)) hits = hits + 10;   // illegal: ref formal in an event expression

  initial begin
    #1 a = 2;
    #1 $display("hits=%0d", hits);
  end
endmodule
