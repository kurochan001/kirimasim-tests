/*
:name: test_illegal_assoc_index_declares_struct
:description: the index type of an associative array cannot itself declare a type, such as a packed structure type (IEEE 1800-2023 Section 7.8)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the index type of the associative array bad is the declaration of a packed structure type
:expected_stderr_regex: test_illegal_assoc_index_declares_struct\.sv:32:
*/
// IEEE 1800-2023 §7.8: the index type between the brackets of an associative
// array is a data type used as the lookup key, or *, and it shall be illegal
// for it to declare a type.
// The array ok is indexed by the type key_t, declared before it as a packed
// structure type; the legal design writes two entries and prints the number of
// entries: 2. The array bad declares a packed structure type in its brackets.
// Icarus Verilog 13.0 does not support associative arrays with an index type
// and reports errors on their declarations and uses, which do not count.
// The 5.052 release accepts the design.

module test_illegal_assoc_index_declares_struct;
  typedef struct packed { bit [3:0] hi, lo; } key_t;
  int ok [key_t];
  initial begin
    ok[key_t'(0)] = 1;
    ok[key_t'(1)] = 2;
    $display("%0d", ok.num());
  end
  int bad [struct packed { bit [3:0] hi, lo; }];   // illegal: the index type declares a type
endmodule
