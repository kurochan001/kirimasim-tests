/*
:name: test_illegal_let_event_formal_unpacked_array_actual
:description: the actual argument of a let formal of type event has to be an event expression, which an unpacked array is not (IEEE 1800-2023 Section 11.12)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the unpacked array arr is the actual argument of the event formal ev of the let rose_on, and an event expression has to give a singular value
:expected_stderr_regex: test_illegal_let_event_formal_unpacked_array_actual\.sv:(35|39):
*/
// IEEE 1800-2023 §11.12: when a formal argument of a let is of type event,
// its actual argument shall be an event expression and every reference to
// the formal shall be in a place where an event expression may be written.
// §9.4.2: an event expression shall give a singular value. In rose_on the
// formal ev is referenced in the clocking event @(ev) of $rose (§16.9.3), a
// place for an event expression. The actual clk of the first use is a
// singular event expression, which is legal; the actual arr of the second
// use is an unpacked array of two ints and is not an event expression. A
// tool can report the error where arr is passed (line 39) or at the clocking
// event of the let body (line 35).
// Icarus Verilog 13.0 does not support let declarations, and the 5.054
// release of Verilator reports typed let ports as unsupported and does not
// parse the clocking event in the let body; none of these errors is the
// diagnostic of this rule.

module test_illegal_let_event_formal_unpacked_array_actual;
  logic clk = 1'b0;
  logic a = 1'b0;
  int arr [2];
  bit r, q;

  let rose_on(x, event ev) = $rose(x, @(ev));

  initial begin
    r = rose_on(a, clk);
    q = rose_on(a, arr);   // illegal: an unpacked array as an event expression
  end
endmodule
