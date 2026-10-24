/*
:name: test_semaphore_try_get_shortfall_takes_nothing
:description: a semaphore try_get() that asks for more keys than are available returns 0 at once, without waiting for keys put later, and leaves every available key in the bucket, whether some, none or a negative count is available (IEEE 1800-2023 Section 15.3.4)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.3.4 15.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_semaphore_try_get_shortfall_takes_nothing.expected
*/
// IEEE 1800-2023 §15.3.4: try_get() obtains the requested keys only if that
// many are available; otherwise it returns 0 and does not block. Taking no
// key in that case is what keeps the count of available keys unchanged.
//
// keys() counts the keys that try_get(1) can take one by one (at most 20)
// and puts them back, so it shows the exact number available. With three
// keys, try_get(5) and try_get(4) return 0 at t=0 although another process
// puts ten keys at t=5, and the three keys stay; after two more keys are
// put, try_get(5) takes all five. On a bucket made with -1 keys, a failed
// try_get(1) leaves the count at -1, so it takes two puts of one key before
// one key is available.
`timescale 1ns/1ns

module test_semaphore_try_get_shortfall_takes_nothing;
  semaphore s, sn;
  int r;

  function automatic int keys(semaphore h);
    int n = 0;
    while (n < 20 && h.try_get(1) > 0) n++;
    if (n > 0) h.put(n);
    return n;
  endfunction

  initial begin
    s = new(3);
    fork
      #5 s.put(10);
    join_none
    r = s.try_get(5);
    $display("3 keys, try_get(5): result=%0d t=%0d keys=%0d", r, $time, keys(s));
    r = s.try_get(4);
    $display("3 keys, try_get(4): result=%0d t=%0d keys=%0d", r, $time, keys(s));
    s.put(2);
    $display("put(2): keys=%0d", keys(s));
    r = s.try_get(5);
    $display("5 keys, try_get(5): positive=%0d keys=%0d", r > 0, keys(s));
    r = s.try_get(1);
    $display("0 keys, try_get(1): result=%0d t=%0d keys=%0d", r, $time, keys(s));
    #6 $display("t=%0d after the put of 10: keys=%0d", $time, keys(s));

    sn = new(-1);
    r = sn.try_get(1);
    $display("-1 keys, try_get(1): result=%0d", r);
    sn.put(1);
    r = sn.try_get(1);
    $display("put(1), try_get(1): result=%0d", r);
    sn.put(1);
    $display("put(1): keys=%0d", keys(sn));
  end
endmodule
