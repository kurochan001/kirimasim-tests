/*
:name: test_semaphore_keys_limit_concurrent_holders
:description: the keys of a semaphore bound how many processes hold one at a time; the others wait until enough keys are returned, a request for two keys waits while only one is free, and waiters resume in the order they started waiting (IEEE 1800-2023 Section 15.3)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.3 15.3.3 15.3.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_semaphore_keys_limit_concurrent_holders.expected
*/
// IEEE 1800-2023 §15.3: a semaphore is a bucket of keys; a process has to
// obtain a key before it goes on, so with a fixed number of keys only that
// many processes can be past the get() at once, and the others wait until
// enough keys are returned. §15.3.3: a get() for more keys than are
// available blocks, and the waiting queue keeps the order of arrival.
//
// Phase 1: four workers take one key of a bucket of two, hold it for 10
// units and return it. At t=5 and t=15 two workers hold a key and the
// counts of finished workers are 0 and 2; all four have finished at t=25,
// and no more than two ever held a key at once. Which two workers go first
// is not printed. Phase 2: a worker holds one of two keys from t=30 to
// t=40; a get(2) started at t=31 has to wait until t=40, although one key
// is free from t=31. Phase 3: with no key, w1 starts waiting at t=50 and w2
// at t=51; one key put at t=60 goes to w1 and one put at t=70 to w2.
`timescale 1ns/1ns

module test_semaphore_keys_limit_concurrent_holders;
  semaphore s;
  int active = 0, peak = 0, finished = 0;
  int big_at = -1, w1_at = -1, w2_at = -1;

  task automatic worker();
    s.get(1);
    active++;
    if (active > peak) peak = active;
    #10;
    active--;
    finished++;
    s.put(1);
  endtask

  initial begin
    s = new(2);
    repeat (4) fork worker(); join_none
    #5 $display("t=%0d: holding=%0d finished=%0d", $time, active, finished);
    #10 $display("t=%0d: holding=%0d finished=%0d", $time, active, finished);
    #10 $display("t=%0d: holding=%0d finished=%0d peak=%0d", $time, active, finished, peak);

    #5;
    fork
      begin
        s.get(1);
        #10 s.put(1);
      end
      begin
        #1 s.get(2);
        big_at = $time;
        s.put(2);
      end
    join
    $display("get(2) started at t=31 returned at t=%0d", big_at);

    #10;
    s.get(2);
    fork
      begin
        s.get(1);
        w1_at = $time;
      end
      begin
        #1 s.get(1);
        w2_at = $time;
      end
    join_none
    #10 s.put(1);
    #10 s.put(1);
    #1 $display("w1 (waiting from t=50) got its key at t=%0d, w2 (from t=51) at t=%0d",
                w1_at, w2_at);
  end
endmodule
