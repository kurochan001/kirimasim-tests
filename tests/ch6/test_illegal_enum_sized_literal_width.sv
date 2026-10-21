/*
:name: test_illegal_enum_sized_literal_width
:description: A sized literal that sets an enum value must have the width of the base type (IEEE 1800-2023 Section 6.19)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.19
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an enum value is a sized literal narrower than the base type
:expected_stderr_regex: test_illegal_enum_sized_literal_width\.sv:20:
*/
// IEEE 1800-2023 §6.19: when the value of an enum name is a sized literal
// constant, it shall be an error if its size differs from the size of the enum
// base type, even when the value fits.
// The design is accepted by Verilator 5.052 (docs/simulator-differences.md).

module test_illegal_enum_sized_literal_width;
  enum logic [3:0] {IDLE = 4'd0, RUN = 2'd1, DONE = 4'd2} state;   // illegal: 2'd1 for a 4-bit base
  initial begin
    state = RUN;
    $display("state=%0d", state);
  end
endmodule
