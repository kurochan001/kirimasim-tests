/*
:name: test_illegal_enum_parameter_assigned_int
:description: the value assigned to a parameter with an explicit type has to be assignment compatible with that type; an int value is not, for an enum-typed parameter (IEEE 1800-2023 Section 6.20.2)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.2 6.22.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the enum-typed parameter BAD is assigned the int literal 2, which is not assignment compatible with the enum type
:expected_stderr_regex: test_illegal_enum_parameter_assigned_int\.sv:28:
*/
// IEEE 1800-2023 §6.20.2: in an assignment to a parameter with an explicit
// type, the right-hand expression shall be assignment compatible with the
// type. §6.22.3: an enum converts to an integral type without a cast, but
// not the other way around. MODE takes a member of its enum type, LEVEL, an
// int parameter, takes an enum member, and SCALE, a real parameter, takes an
// integer; BAD, of the enum type, takes the int literal 2.
// Icarus Verilog 13.0 accepts the design.

module test_illegal_enum_parameter_assigned_int;
  typedef enum {IDLE, RUN, STOP} mode_t;
  parameter mode_t MODE = RUN;
  parameter int LEVEL = STOP;
  parameter real SCALE = 3;
  initial $display("%0d %0d %0.1f", MODE, LEVEL, SCALE);
  parameter mode_t BAD = 2;   // illegal: int value for an enum parameter
endmodule
