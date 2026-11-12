/*
:name: test_cast_task_enum_value_runtime_error
:description: $cast called as a task with a value computed at run time that is not a member of the destination enumeration gives a run-time error and leaves the destination unchanged (IEEE 1800-2023 Section 6.24.2)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.2 6.19.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_task_enum_value_runtime_error.expected
:expected_stderr_regex: (?i:\berror\b)
*/
// IEEE 1800-2023 §6.24.2: $cast called as a task tries to assign the source
// to the destination. When the assignment is invalid, a run-time error
// occurs and the destination variable is left unchanged; the compiler does
// no type checking. The example of the clause casts 2 + 8 to an enumeration
// of six members and calls it an invalid cast, so a value outside the
// enumeration makes the assignment invalid (see also §6.19.3). The source v
// is a variable, so only the run knows its value. The first call casts 2,
// the value of B, and is valid. The second call casts 9, which no member
// has: the messages of the run are checked for an error, whose form the
// standard leaves to the tool, and the line printed after the call shows
// that e still holds B. An implementation that stores 9 prints e=9 there,
// and one that reports no error fails the check of the messages.
// The last expected line assumes that the run goes on after the run-time
// error. The standard does not say so in so many words; it fixes the state
// (the destination is left unchanged), which only a run that goes on can show.
// The sentence of the clause that defines an invalid assignment speaks of
// types that are not cast compatible, while its example calls a value outside
// the enumeration an invalid cast; this test follows the example.
// Icarus Verilog 13.0 does not support $cast.

typedef enum int {A = 1, B = 2} test_cast_task_enum_value_et;

module test_cast_task_enum_value_runtime_error;
  test_cast_task_enum_value_et e;
  int v;

  initial begin
    e = A;
    v = 1 + 1;
    $cast(e, v);
    $display("valid cast of %0d: e=%0d", v, e);
    v = v + 7;
    $display("calling $cast(e, %0d)", v);
    $cast(e, v);
    $display("after the invalid cast: e=%0d", e);
  end
endmodule
