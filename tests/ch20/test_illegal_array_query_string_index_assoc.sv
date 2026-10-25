/*
:name: test_illegal_array_query_string_index_assoc
:description: an array query function cannot be applied to an associative array dimension whose index type is not integral (IEEE 1800-2023 Section 20.7)
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: $left is applied to by_name, an associative array indexed by string, which is not an integral index type
:expected_stderr_regex: test_illegal_array_query_string_index_assoc\.sv:29:
*/
// IEEE 1800-2023 §20.7: the array query functions may be used on an
// associative array dimension only when its index type is integral. by_name
// is indexed by string; by_num, indexed by int, may be queried, as on the
// line before.
// Icarus Verilog 13.0 rejects the declarations of the associative arrays,
// and in its 5.052 release the Verilator tool accepts the design.

module test_illegal_array_query_string_index_assoc;
  int by_name [string];
  int by_num [int];

  initial begin
    by_name["a"] = 1;
    by_num[4] = 1;
    $display("%0d", $left(by_num));
    $display("%0d", $left(by_name));   // illegal: the index type string is not integral
  end
endmodule
