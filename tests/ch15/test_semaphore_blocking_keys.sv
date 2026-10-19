/*
:name: test_semaphore_blocking_keys
:description: Semaphore get waits until enough keys have been put back, and try_get fails without waiting (IEEE 1800-2023 Section 15.3.3)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.3.3 15.3.2 15.3.1 15.3.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_semaphore_blocking_keys.expected
*/
// IEEE 1800-2023 §15.3.1: new(n) makes a semaphore with n keys. §15.3.3:
// get(k) takes k keys if that many are available and otherwise waits until
// they are. §15.3.2: put(k) returns k keys. So a process waiting for 2 keys
// does not continue when one key comes back, only when the second one does.
// §15.3.4: try_get(k) never waits; it returns 0 when there are not enough
// keys and a positive value when it takes them.

`timescale 1ns/1ns

module test_semaphore_blocking_keys;
  semaphore s;
  int t_got = -1;
  int r;

  initial begin
    s = new(2);
    s.get(2);
    fork
      begin s.get(2); t_got = $time; end
    join_none
    #5 s.put(1);
    #1 $display("%0d: after one key came back, waiter got keys at %0d", $time, t_got);
    #4 s.put(1);
    #1 $display("%0d: waiter got keys at %0d", $time, t_got);
    r = s.try_get(1);
    $display("try_get with no keys: %0d", r);
    s.put(3);
    r = s.try_get(2);
    $display("try_get of 2 with 3 keys: ok=%0d", r > 0);
    r = s.try_get(2);
    $display("try_get of 2 with 1 key: %0d", r);
  end
endmodule
