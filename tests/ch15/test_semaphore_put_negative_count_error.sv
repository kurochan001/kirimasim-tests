/*
:name: test_semaphore_put_negative_count_error
:description: put() with a negative key count is a run-time error (IEEE 1800-2023 Section 15.3.2)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.3.2 15.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_semaphore_put_negative_count_error.expected
:expected_stderr_regex: (?i:\berror\b)
*/
// IEEE 1800-2023 §15.3.2: the argument of put() is the number of keys given
// back to the semaphore, and a negative number shall result in an error.
// §15.3.1 allows a negative initial count in new(), so this test does not use
// one: the semaphore starts with 2 keys, and only the put() call has a
// negative count. The count is computed at run time, so the error is one of
// the run. Before the call, a put(1) and a try_get(3) show that the semaphore
// works: after the put it has 3 keys, and try_get(3) takes them all. The
// standard does not say what put() does with the keys after the error or
// whether the run goes on, so nothing is printed after the call; the messages
// of the run are checked for an error, whose form the standard leaves to the
// tool.
// Icarus Verilog 13.0 does not support semaphores, and Verilator 5.052 runs
// the call without an error.

module test_semaphore_put_negative_count_error;
  semaphore s;
  int n;

  initial begin
    s = new(2);
    s.put(1);
    $display("put(1), try_get(3) = %0d", s.try_get(3) > 0);
    n = 1 - 2;
    $display("calling put(%0d)", n);
    s.put(n);
  end
endmodule
