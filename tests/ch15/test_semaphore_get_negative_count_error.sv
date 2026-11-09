/*
:name: test_semaphore_get_negative_count_error
:description: get() with a negative key count is a run-time error (IEEE 1800-2023 Section 15.3.3)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.3.3 15.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_semaphore_get_negative_count_error.expected
:expected_stderr_regex: (?i:\berror\b)
*/
// IEEE 1800-2023 §15.3.3: the argument of get() is the number of keys to take
// from the semaphore, and a negative number shall result in an error. §15.3.1
// allows a negative initial count in new(), so this test does not use one: the
// semaphore starts with 2 keys, and only the get() call has a negative count.
// The count is computed at run time, so the error is one of the run. Before
// the call, get(2) returns at once at time 0 and a put(2) gives the keys back.
// The standard does not say whether get() blocks or returns after the error,
// nor whether the run goes on, so nothing is printed after the call; the
// messages of the run are checked for an error, whose form the standard
// leaves to the tool.
// Icarus Verilog 13.0 does not support semaphores, and Verilator 5.052 runs
// the call without an error.

`timescale 1ns/1ns

module test_semaphore_get_negative_count_error;
  semaphore s;
  int n;

  initial begin
    s = new(2);
    s.get(2);
    $display("get(2) returned at t=%0t", $time);
    s.put(2);
    n = 1 - 2;
    $display("calling get(%0d)", n);
    s.get(n);
  end
endmodule
