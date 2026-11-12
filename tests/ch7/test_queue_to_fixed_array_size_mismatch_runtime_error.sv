/*
:name: test_queue_to_fixed_array_size_mismatch_runtime_error
:description: Assigning a queue to a fixed-size array with a different number of elements gives a run-time error and performs no operation (IEEE 1800-2023 Section 7.6)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_to_fixed_array_size_mismatch_runtime_error.expected
:expected_stderr_regex: (?i:\berror\b)
*/
// IEEE 1800-2023 §7.6: when a dynamic array or a queue is assigned to a
// fixed-size array, the size of the source is known only at run time. An
// attempt to copy a source with a different number of elements into the
// fixed-size array shall result in a run-time error, and no operation shall
// be performed. The source here is a queue whose size comes from the
// variable n. With three elements the assignment to f, which has three, is
// legal and copies 4 5 6. With two elements the same assignment shall give
// the error: the messages of the run are checked for an error, whose form
// the standard leaves to the tool, and the line printed after the
// assignment shows that f still holds 4 5 6. An implementation that copies
// the two elements prints 7 8 6 there (or other values in f), and one that
// reports no error fails the check of the messages.
// The last expected line assumes that the run goes on after the run-time
// error. The standard does not say so in so many words; it fixes the state
// (no operation is performed), which only a run that goes on can show.
// Icarus Verilog 13.0 and Verilator 5.052 reject the assignment of a queue
// to a fixed-size array, the legal one too.

module test_queue_to_fixed_array_size_mismatch_runtime_error;
  int f[3];
  int d[$];
  int n;

  initial begin
    n = 1 + 2;
    for (int i = 0; i < n; i++) d.push_back(4 + i);
    f = d;
    $display("%0d elements: f = %0d %0d %0d", d.size(), f[0], f[1], f[2]);
    void'(d.pop_back());
    d[0] = 7;
    d[1] = 8;
    $display("assigning %0d elements to f", d.size());
    f = d;
    $display("after the assignment: f = %0d %0d %0d", f[0], f[1], f[2]);
  end
endmodule
