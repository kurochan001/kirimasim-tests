/*
:name: test_illegal_enum_assign_arithmetic_without_cast
:description: an expression whose type is not equivalent to an enum type, such as an enum value plus one, needs a cast to be assigned to an enum variable, while a value of an equivalent typedef needs none (IEEE 1800-2023 Section 6.19.4)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.19.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the int expression c + 1 is assigned to the enum variable c without a cast
:expected_stderr_regex: test_illegal_enum_assign_arithmetic_without_cast\.sv:30:
*/
// IEEE 1800-2023 §6.19.4: an enum value used in an expression is cast to the
// base type of the enum, so c + 1 has the type int. A cast is required when
// an expression is assigned to an enum variable and its type is not
// equivalent to the enum type. hue_t renames color_t, so a hue_t value is
// assigned to c without a cast; c + 1 is assigned once through a cast,
// which is legal, and once without one.

module test_illegal_enum_assign_arithmetic_without_cast;
  typedef enum {RED, GREEN, BLUE} color_t;
  typedef color_t hue_t;
  color_t c;
  hue_t h = GREEN;
  initial begin
    c = h;
    c = color_t'(c + 1);
    $display("%0d", c);
    c = c + 1;   // illegal: an int expression assigned to color_t
  end
endmodule
