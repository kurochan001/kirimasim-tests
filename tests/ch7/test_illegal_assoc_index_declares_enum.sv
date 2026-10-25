/*
:name: test_illegal_assoc_index_declares_enum
:description: the index type of an associative array cannot itself declare a type, such as an enumerated type (IEEE 1800-2023 Section 7.8)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the index type of the associative array bad is the declaration of an enumerated type
:expected_stderr_regex: test_illegal_assoc_index_declares_enum\.sv:33:
*/
// IEEE 1800-2023 §7.8: the index type between the brackets of an associative
// array is a data type used as the lookup key, or *, and it shall be illegal
// for it to declare a type.
// The array ok is indexed by the type key_t, declared before it as an
// enumerated type; the legal design writes two entries and prints the number of
// entries: 2. The array bad declares an enumerated type in its brackets, whose
// names differ from those of key_t so that no name is declared twice.
// Icarus Verilog 13.0 does not support associative arrays with an index type
// and reports errors on their declarations and uses, which do not count.
// The 5.052 release accepts the design.

module test_illegal_assoc_index_declares_enum;
  typedef enum {RED, GREEN} key_t;
  int ok [key_t];
  initial begin
    ok[key_t'(0)] = 1;
    ok[key_t'(1)] = 2;
    $display("%0d", ok.num());
  end
  int bad [enum {CYAN, MAGENTA}];   // illegal: the index type declares a type
endmodule
