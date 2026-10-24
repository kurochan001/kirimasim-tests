/*
:name: test_queue_invalid_index_write_ignored_warning
:description: a write to a queue with an index below 0, above $+1, or with an x or z bit is ignored with a run-time warning, while a write to [$+1] appends an element (IEEE 1800-2023 Section 7.10.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_queue_invalid_index_write_ignored_warning.expected
:expected_stderr_regex: (?i:\bwarn(?:ing)?\b|%Warning-)
*/
// IEEE 1800-2023 §7.10.1: for a write, an index of a queue is invalid when it
// is a 4-state value with x or z bits or lies outside 0 to $+1; the write is
// then ignored and a run-time warning shall be issued. A write to Q[$+1] is
// legal and adds an element at the end.
// The four invalid writes leave q as it was, which the output shows, and the
// warning they require is checked in the messages of the run. The test makes
// no invalid read, so no other warning is expected from it. The write to
// index 3, $+1 of a three-element queue, then appends 8.

module test_queue_invalid_index_write_ignored_warning;
  int q[$] = '{5, 6, 7};
  int neg = -1;
  int far = 5;
  logic [1:0] xi = 2'b1x;
  logic [1:0] zi = 2'bz1;

  initial begin
    q[neg] = 90;
    q[far] = 91;
    q[xi] = 92;
    q[zi] = 93;
    $display("after invalid writes: size=%0d %0d %0d %0d", q.size(), q[0], q[1], q[2]);
    q[3] = 8;
    $display("after q[$+1] write: size=%0d last=%0d", q.size(), q[$]);
  end
endmodule
