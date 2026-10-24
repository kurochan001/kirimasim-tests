/*
:name: test_semaphore_get_try_get_int_count_default_one
:description: semaphore get() is a task that blocks until its keys are there and try_get() a function returning int; both take an int key count that defaults to 1 (IEEE 1800-2023 Sections 15.3.3 and 15.3.4)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.3.3 15.3.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_semaphore_get_try_get_int_count_default_one.expected
*/
// IEEE 1800-2023 §15.3.3: get() is a task with one int argument, the number
// of keys, whose default is 1; when fewer keys are available, the calling
// process blocks until they are. §15.3.4: try_get() is a function returning
// int, with the same int argument and default; it returns a positive value
// when it obtains the keys and 0 when it does not.
//
// keys() counts the keys that try_get(1) can take one by one (at most 20)
// and puts them back. get() and try_get() without an argument take exactly
// one key. As the argument is int, 64'h1_0000_0002 is truncated to 2 and
// the real 1.6 is rounded to 2 when passed. get(3) with two keys available
// returns only at t=3, when another process puts two more keys. $typename shows
// the type of the try_get() call without evaluating it (20.6.1), so it
// takes no key.
`timescale 1ns/1ns

module test_semaphore_get_try_get_int_count_default_one;
  semaphore s;
  int r;

  function automatic int keys(semaphore h);
    int n = 0;
    while (n < 20 && h.try_get(1) > 0) n++;
    if (n > 0) h.put(n);
    return n;
  endfunction

  initial begin
    s = new(4);
    s.get();
    $display("new(4), get(): keys=%0d", keys(s));
    s.get(64'h1_0000_0002);
    $display("get(64'h1_0000_0002): keys=%0d t=%0d", keys(s), $time);
    s.put(3);
    s.get(1.6);
    $display("put(3), get(1.6): keys=%0d t=%0d", keys(s), $time);
    fork
      #3 s.put(2);
    join_none
    s.get(3);
    $display("get(3) with 2 keys returned at t=%0d, keys=%0d", $time, keys(s));

    s = new(4);
    $display("try_get() has type %s, keys=%0d", $typename(s.try_get()), keys(s));
    r = s.try_get();
    $display("try_get(): positive=%0d keys=%0d", r > 0, keys(s));
    r = s.try_get(64'h1_0000_0002);
    $display("try_get(64'h1_0000_0002): positive=%0d keys=%0d", r > 0, keys(s));
    r = s.try_get(1.6);
    $display("try_get(1.6): result=%0d keys=%0d", r, keys(s));
    r = s.try_get();
    $display("try_get(): positive=%0d keys=%0d", r > 0, keys(s));
    r = s.try_get();
    $display("try_get() with no key: result=%0d keys=%0d", r, keys(s));
  end
endmodule
