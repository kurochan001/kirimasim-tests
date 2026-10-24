/*
:name: test_class_cast_task_failure_reports_error
:description: $cast called as a task on a class handle that refers to an object of the base class, not of the destination class, fails with a run-time error (IEEE 1800-2023 Section 8.16)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.16 6.24.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_cast_task_failure_reports_error.expected
:expected_stderr_regex: (?i:\berror\b)
*/
// IEEE 1800-2023 §8.16: a downcast with $cast succeeds only when the source
// refers to an object that can be assigned to the destination; otherwise the
// error handling of §6.24.2 applies, and when $cast is called as a task a
// failing cast is a run-time error. bh refers to a base_c object, so the task
// call $cast(dh, bh) has to report an error, which the messages of the run
// are checked for. The standard does not say whether the run goes on after
// the error, so nothing is printed after the cast.
// Icarus Verilog 13.0 does not support $cast.

module test_class_cast_task_failure_reports_error;
  class base_c;
    int b = 1;
  endclass
  class der_c extends base_c;
    int d = 2;
  endclass

  base_c bh;
  der_c dh;

  initial begin
    bh = new;
    $display("casting a base_c object to der_c with the task form");
    $cast(dh, bh);
  end
endmodule
