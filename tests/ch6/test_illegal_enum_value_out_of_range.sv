/*
:name: test_illegal_enum_value_out_of_range
:description: An enum value cannot lie outside the range of the base type (IEEE 1800-2023 Section 6.19)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.19
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an enum name is given a value that its 2-bit base type cannot represent
:expected_stderr_regex: test_illegal_enum_value_out_of_range\.sv:18:
*/
// IEEE 1800-2023 §6.19: an encoding value outside the range that the enum base
// type can represent shall be an error; a 2-bit base type holds 0 to 3.

module test_illegal_enum_value_out_of_range;
  enum bit [1:0] {LOW = 0, MID = 2, HIGH = 5} level;   // illegal: 5 does not fit in 2 bits
  initial begin
    level = MID;
    $display("level=%0d", level);
  end
endmodule
