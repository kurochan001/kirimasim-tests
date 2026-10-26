/*
:name: test_cast_function_and_static_enum_coercion
:description: $cast as a function returns int and leaves the destination unchanged on failure, while a static enum cast coerces without checking
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.2 6.24.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_function_and_static_enum_coercion.expected
*/
// IEEE 1800-2023 6.24.2: $cast takes the destination variable first and the
// source second. Called as a function it returns int (1 when the assignment is
// made, 0 when it is not) and never issues an error; a failed cast leaves the
// destination unchanged. Called as a task it has no return value. 6.24.1: a
// static cast to an enum destination coerces the value without a run-time
// membership check. The test performs both directions on an enum whose members
// are 1, 3 and 5 and prints the returned int, the destination and the coerced
// out-of-range value.

typedef enum bit [2:0] {A = 3'd1, B = 3'd3, C = 3'd5} etri_t;

module test_cast_function_and_static_enum_coercion;
  etri_t e;
  int ok;
  int task_result;

  initial begin
    e = B;
    ok = $cast(e, 3'd1);
    $display("fn_ok=%0d e=%0d", ok, e);
    ok = $cast(e, 3'd6);
    $display("fn_bad=%0d e=%0d", ok, e);
    ok = $cast(e, 3'd5);
    $display("fn_two=%0d e=%0d", ok, e);
    $cast(e, 3'd3);
    $display("task_ok e=%0d", e);
    e = etri_t'(3'd7);
    $display("coerced e=%0d", e);
    task_result = 9;
    $display("task_result=%0d", task_result);
  end
endmodule
