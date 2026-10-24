/*
:name: test_illegal_sequence_typed_formal_actual_not_cast_compatible
:description: the actual of a typed sequence formal has to be cast compatible with its type (IEEE 1800-2023 Section 16.8.1)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance of s_c in p_bad passes the unpacked array arr to the formal x of type int
:expected_stderr_regex: test_illegal_sequence_typed_formal_actual_not_cast_compatible\.sv:31:
*/
// IEEE 1800-2023 §16.8.1: the self-determined type of the actual of a typed
// formal, other than one of type sequence or event, shall be cast compatible
// (6.22.4) with the type of the formal. p_byte passes a byte and p_real a
// real, both cast compatible with int; p_bad passes the unpacked array arr.
// Icarus Verilog 13.0 does not support concurrent assertions; the syntax
// errors it reports do not count.

module test_illegal_sequence_typed_formal_actual_not_cast_compatible;
  logic clk = 0, a = 0;
  byte bv = 1;
  real rv = 1.0;
  int arr [2];
  sequence s_c(int x);
    a ##1 (x == 1);
  endsequence
  p_byte: assert property (@(posedge clk) s_c(bv));
  p_real: assert property (@(posedge clk) s_c(rv));
  p_bad: assert property (@(posedge clk) s_c(arr));   // illegal
endmodule
