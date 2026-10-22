/*
:name: test_assoc_class_null_and_alias_keys
:description: A class indexed associative array accepts null and aliases identify the same object key (IEEE 1800-2023 Section 7.8.3)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_class_null_and_alias_keys.expected
*/
// IEEE 1800-2023 7.8.3: Class keys may be null or objects of a derived type.
// Two handles of the same object address one entry; no arbitrary object order
// is assumed.
// Oracle checks: Icarus Verilog 13.0 does not build this case.

module test_assoc_class_null_and_alias_keys;
  class key_base; endclass
  class key_child extends key_base; endclass
  int values[key_base];
  key_base a, alias_key;
  key_child b;
  initial begin
    a = new; b = new; alias_key = a;
    values[null] = 5; values[a] = 7; values[b] = 11; values[alias_key] = 9;
    $display("size=%0d null=%0d base=%0d derived=%0d", values.num(),
             values[null], values[a], values[b]);
  end
endmodule
