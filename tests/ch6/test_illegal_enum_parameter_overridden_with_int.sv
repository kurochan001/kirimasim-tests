/*
:name: test_illegal_enum_parameter_overridden_with_int
:description: the value that overrides a parameter with an explicit type has to be assignment compatible with that type; an int value is not, for an enum-typed parameter (IEEE 1800-2023 Section 6.20.2)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.2 6.22.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance bad overrides the enum-typed parameter MODE with the int literal 2, which is not assignment compatible with the enum type
:expected_stderr_regex: test_illegal_enum_parameter_overridden_with_int\.sv:35:
*/
// IEEE 1800-2023 §6.20.2: in an override of a parameter with an explicit
// type, the type of the overriding expression shall be assignment compatible
// with the declared type. §6.22.3: an enum converts to an integral type
// without a cast, but not the other way around. The instance ok gives MODE
// a member of its enum type and LEVEL, an int parameter, an enum member;
// the instance bad gives MODE the int literal 2.
// Icarus Verilog 13.0 accepts the design.

package test_illegal_enum_parameter_overridden_with_int_pkg;
  typedef enum {IDLE, RUN, STOP} mode_t;
endpackage

module test_illegal_enum_parameter_overridden_with_int_m
    import test_illegal_enum_parameter_overridden_with_int_pkg::*;
    #(parameter mode_t MODE = IDLE, parameter int LEVEL = 0) ();
  initial $display("%0d %0d", MODE, LEVEL);
endmodule

module test_illegal_enum_parameter_overridden_with_int;
  import test_illegal_enum_parameter_overridden_with_int_pkg::*;
  test_illegal_enum_parameter_overridden_with_int_m #(.MODE(RUN), .LEVEL(STOP)) ok();
  test_illegal_enum_parameter_overridden_with_int_m #(.MODE(2)) bad();   // illegal: int for MODE
endmodule
