/*
:name: test_illegal_enum_same_name_two_enums
:description: Two enumerations in the same scope cannot both have a name LOW, since enum names are not overloaded (IEEE 1800-2023 Section 6.19)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.19
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the name LOW is declared by two different enumerated types in the same scope
:expected_stderr_regex: test_illegal_enum_same_name_two_enums\.sv:21:
*/
// IEEE 1800-2023 §6.19: enum names are not overloaded, so two enumerated
// types that use the same name cannot be declared in the same scope, even
// when their base types differ. level_t declares LOW, and power_t declares
// LOW again in the same module.

module test_illegal_enum_same_name_two_enums;
  typedef enum {LOW, HIGH} level_t;
  typedef enum bit [1:0] {OFF, LOW} power_t;    // illegal: LOW already names a level_t value
  level_t l;
  power_t p;
  initial begin
    l = HIGH;
    p = OFF;
  end
endmodule
