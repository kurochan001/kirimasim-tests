/*
:name: test_unpacked_concat_typed_array_and_string_item
:description: A typed array item expands but a string concatenation stays one element in an unpacked concatenation (IEEE 1800-2023 Section 10.10.1)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.10.1 10.10.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unpacked_concat_typed_array_and_string_item.expected
*/
// IEEE 1800-2023 10.10.1 10.10.3: Array concatenation can mix scalar elements
// and arrays; a nested concatenation with string operands is a singular string
// item rather than a nested array.
// Oracle checks: Icarus Verilog 13.0 does not build this case. The 5.052
// release does not reproduce the clause-derived output.

module test_unpacked_concat_typed_array_and_string_item;
  typedef string strings_t[$];
  string prefix = "pre", suffix = "post";
  strings_t a, b;
  initial begin
    a = {prefix, {"mid", suffix}};
    b = {prefix, strings_t'{"mid", suffix}};
    $display("singular_size=%0d items=%s,%s", a.size(), a[0], a[1]);
    $display("array_size=%0d items=%s,%s,%s", b.size(), b[0], b[1], b[2]);
  end
endmodule
