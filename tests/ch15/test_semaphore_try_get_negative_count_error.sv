/*
:name: test_semaphore_try_get_negative_count_error
:description: try_get() with a negative key count returns 0 and is a run-time error (IEEE 1800-2023 Section 15.3.4)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.3.4 15.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_semaphore_try_get_negative_count_error.expected
:expected_stderr_regex: (?i:\berror\b)
*/
// IEEE 1800-2023 §15.3.4: if the key count of try_get() is negative, the
// method returns 0 and the call shall result in an error. §15.3.1 allows a
// negative initial count in new(), so this test does not use one: the
// semaphore starts with 2 keys, and only the try_get() call has a negative
// count. The count is computed at run time, so the error is one of the run.
// Since the method returns 0, the process goes on and prints the result of the
// call. A try_get(1) before it returns a positive value, printed as 1. The
// messages of the run are checked for an error, whose form the standard leaves
// to the tool.
// Icarus Verilog 13.0 does not support semaphores, and Verilator 5.052
// returns 1 without an error.

module test_semaphore_try_get_negative_count_error;
  semaphore s;
  int n, r;

  initial begin
    s = new(2);
    $display("try_get(1) positive: %0d", s.try_get(1) > 0);
    s.put(1);
    n = 1 - 2;
    r = s.try_get(n);
    $display("try_get(%0d) returned %0d", n, r);
  end
endmodule
