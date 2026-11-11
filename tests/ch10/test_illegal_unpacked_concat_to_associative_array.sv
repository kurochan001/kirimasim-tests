/*
:name: test_illegal_unpacked_concat_to_associative_array
:description: the target of an unpacked array concatenation has to be a fixed-size, dynamic or queue array, not an associative array (IEEE 1800-2023 Section 10.10)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the unpacked array concatenation {b, c} is assigned to the associative array aa
:expected_stderr_regex: test_illegal_unpacked_concat_to_associative_array\.sv:34:
*/
// IEEE 1800-2023 §10.10: the target of an unpacked array concatenation shall
// be an array whose slowest-varying dimension is a fixed-size, queue or
// dynamic unpacked dimension; any other target, an associative array among
// them, shall be illegal. The fixed-size array f2, the dynamic array d and
// the queue q are legal targets; the associative array aa is not.
// Icarus Verilog 13.0 rejects the declaration of the associative array, and
// the 5.052 release of Verilator reports the concatenation as unsupported,
// so neither error counts.

module test_illegal_unpacked_concat_to_associative_array;
  int f2 [2];
  int d [];
  int q [$];
  int aa [int];
  int b = 5, c = 6;

  initial begin
    f2 = {b, c};
    d = {b, c};
    q = {b, c};
    aa = {b, c};   // illegal: an associative array target
    $display("%p %p %p", f2, d, q);
  end
endmodule
