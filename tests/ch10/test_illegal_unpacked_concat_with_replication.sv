/*
:name: test_illegal_unpacked_concat_with_replication
:description: an unpacked array concatenation does not support replication, which an array assignment pattern does (IEEE 1800-2023 Section 10.10.1)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.10.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the replication {3{b}} is assigned to the unpacked array a3, where it would have to be an unpacked array concatenation with replication
:expected_stderr_regex: test_illegal_unpacked_concat_with_replication\.sv:30:
*/
// IEEE 1800-2023 §10.10.1: items of an array assignment pattern can be
// replicated, as in '{3{b}}, but unpacked array concatenations forbid
// replication, so {3{b}} cannot give the three elements of a3 (as a
// replication of the integral b it is a 96-bit vector, not an unpacked
// array). '{3{b}} and the concatenation {b, b, b} are legal; {3{b}} is not.
// Icarus Verilog 13.0 gives a syntax error also on the legal pattern
// replication, and the 5.052 release of Verilator reports the replication
// as unsupported, so neither error counts.

module test_illegal_unpacked_concat_with_replication;
  int a3 [3];
  int b = 2;

  initial begin
    a3 = '{3{b}};
    a3 = {b, b, b};
    a3 = {3{b}};   // illegal: no replication in an unpacked array concatenation
    $display("%p", a3);
  end
endmodule
