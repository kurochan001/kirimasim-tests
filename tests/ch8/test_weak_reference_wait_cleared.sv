/*
:name: test_weak_reference_wait_cleared
:description: A wait on weak_reference get() becoming null resumes when another process clears the reference (IEEE 1800-2023 Section 8.30.3)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.30.3 8.30.4 9.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_weak_reference_wait_cleared.expected
*/
// IEEE 1800-2023 §8.30.3: get() may be used in an event expression to detect
// that a weak reference has been cleared, by the user (8.30.4) or by the
// memory system. One process waits (9.4.3) for get() to be null; the other
// clears the reference at time 5. The referent stays strongly reachable, so
// only clear() can end the wait.

`timescale 1ns/1ns

module test_weak_reference_wait_cleared;
  class token;
  endclass

  token t;
  weak_reference #(token) w;

  initial begin
    t = new();
    w = new(t);
    fork
      begin
        wait (w.get() == null);
        $display("t=%0d: the weak reference was cleared", $time);
      end
      #5 w.clear();
    join
  end
endmodule
