/*
:name: test_pattern_format_enum_value
:description: %p and %P print a valid enum value by its name and a value outside the enumeration by its base type (IEEE 1800-2023 Sections 21.2.1.1 and 21.2.1.6)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.1 21.2.1.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_pattern_format_enum_value.expected
*/
// IEEE 1800-2023 §21.2.1.1: %p and %P display an argument as an assignment
// pattern, and §21.2.1.6 says that an enumerated value is printed by the
// name of its value if the value is valid for the type and otherwise
// according to the base type. The test prints a valid enum value with %p and
// %P and an out-of-range value with %p; the base type is int, whose
// unformatted display is decimal.
//
// Icarus Verilog 13.0 does not support %p, so the output comes from the
// release named in :oracle:.

module test_pattern_format_enum_value;
  typedef enum {OFF, ON, AUTO} mode_t;
  mode_t valid = ON;
  mode_t invalid = mode_t'(9);

  initial begin
    $display("valid=%p", valid);
    $display("upper=%P", valid);
    $display("invalid=%p", invalid);
  end
endmodule
