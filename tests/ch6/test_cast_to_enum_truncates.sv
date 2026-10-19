/*
:name: test_cast_to_enum_truncates
:description: A cast to an enumerated type converts the value to the width of the base type, also when the result is not a member (IEEE 1800-2023 Section 6.24.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.1 6.19.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_to_enum_truncates.expected
*/
// IEEE 1800-2023 §6.24.1: a static cast to an enumerated type gives a value
// of its base type, so the operand is cut to the base type's width, as an
// assignment to the base type would do, and no check is made that the
// result is a member (6.19.4). For a 2-bit base, e_t'(6) is 2 and e_t'(7)
// is 3; e_t'(5) is 1, which is the member B.

module test_cast_to_enum_truncates;
  typedef enum logic [1:0] {A, B, C} e_t;
  e_t e;

  initial begin
    $display("int'(e_t'(6)) = %0d", int'(e_t'(6)));
    $display("int'(e_t'(7)) = %0d", int'(e_t'(7)));
    e = e_t'(5);
    $display("e_t'(5) = %0d %s", e, e.name());
  end
endmodule
