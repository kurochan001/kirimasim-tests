/*
:name: test_illegal_bits_encloses_queue_returning_call
:description: $bits in a procedural statement encloses the call of a function whose return type is a queue, a dynamically sized type (IEEE 1800-2023 Section 20.6.2)
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: $bits encloses the call of make, whose return type bytes_t is a queue of byte
:expected_stderr_regex: ^(?![^\n]*(?i:unsupported|not supported|not implemented|internal error|syntax error))[^\n]*test_illegal_bits_encloses_queue_returning_call\.sv:33:
*/
// IEEE 1800-2023 §20.6.2: $bits gives its result without evaluating the
// expression it encloses, and enclosing a function that returns a
// dynamically sized data type is an error. That sentence does not depend on
// where the call is: here $bits is in a procedural assignment, not in a
// constant expression, so the only rule the design breaks is the one about
// the enclosed function. make returns bytes_t, a queue of byte. The same
// design with a variable bytes_t q and line 33 written as q = make();
// n = $bits(q); is accepted by Icarus Verilog 13.0 and by the 5.054 release
// of Verilator, so nothing else in it is in error.
// Both releases accept this design as well, so the expected rejection
// follows the clause alone.

module test_illegal_bits_encloses_queue_returning_call;
  typedef byte bytes_t[$];
  function automatic bytes_t make();
    return '{8'd1, 8'd2, 8'd3};
  endfunction
  int n;
  initial begin
    n = $bits(make());   // illegal: make returns a queue
    $display("%0d", n);
  end
endmodule
