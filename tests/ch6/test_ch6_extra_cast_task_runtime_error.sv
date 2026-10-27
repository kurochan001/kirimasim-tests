/*
:name: test_ch6_extra_cast_task_runtime_error
:description: An invalid $cast task call is not rejected at compile time; it reports a runtime error and leaves the destination unchanged (IEEE 1800-2023 Section 6.24.2)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.2 6.19.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ch6_extra_cast_task_runtime_error.expected
:expected_stderr_regex: test_ch6_extra_cast_task_runtime_error\.sv:31:
*/
// IEEE 1800-2023 §6.24.2: when $cast is called as a task and the assignment
// is invalid, a run-time error occurs and the destination is left unchanged;
// the compiler does no type checking. 9 is not a member of the enum et, so
// the call on the marked line is invalid, yet the design compiles. The
// destination still holds A after the call. The run continues because the
// error limit of the simulator lets the run go on, as the run-time error of
// the standard does, and the error report is checked with the regular
// expression.
// Icarus Verilog 13.0 has no $cast, so this test has no Icarus oracle.

typedef enum int {A = 1, B = 2} test_ch6_extra_cast_task_et;

module test_ch6_extra_cast_task_runtime_error;
  test_ch6_extra_cast_task_et e;
  initial begin
    e = A;
    $display("before=%0d", e);
    $cast(e, 9);   // illegal: 9 is not a member, a run-time error
    $display("after=%0d", e);
  end
endmodule
