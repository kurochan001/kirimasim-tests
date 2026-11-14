/*
:name: test_illegal_enum_assigned_base_vector_without_cast
:description: assignment compatibility between an enum and an integral type holds in one direction only, so an enum value is assigned to a vector of its base type without a cast but the vector is not assigned back to the enum variable without one (IEEE 1800-2023 Section 6.22.3)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.22.3 6.19.3
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the bit [1:0] variable b is assigned to the enum variable s without a cast
:expected_stderr_regex: test_illegal_enum_assigned_base_vector_without_cast\.sv:28:
*/
// IEEE 1800-2023 §6.22.3: assignment compatibility can hold in one direction
// only; an enum converts to an integral type without a cast, but not the
// other way. §6.19.3: an expression of another type is assigned to an enum
// variable only through a cast. The vector b has the same type as the base
// of state_t. Assigning s to b, and b to s through a cast, is legal; the
// marked line assigns b to s directly, although its value names a member.

module test_illegal_enum_assigned_base_vector_without_cast;
  typedef enum bit [1:0] {IDLE, RUN, STOP} state_t;
  state_t s = RUN;
  bit [1:0] b;
  initial begin
    b = s;
    s = state_t'(b);
    s = b;   // illegal: a bit [1:0] assigned to state_t
    $display("%0d", b);
  end
endmodule
