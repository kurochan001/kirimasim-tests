/*
:name: test_std_semaphore_prototype_defaults
:description: The std::semaphore class has the methods of its Annex G prototype: new with a signed int key count defaulting to 0, put a void function and get a blocking task each defaulting to one key, and try_get an int function defaulting to one key (IEEE 1800-2023 Section 15.3, G.3)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.3 G.3 15.3.1 15.3.2 15.3.3 15.3.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_std_semaphore_prototype_defaults.expected
*/
// IEEE 1800-2023 G.3 gives the prototype of the semaphore class of the std
// package: new and put and try_get are functions and get is a task; each
// takes an int key count, which defaults to 0 for new and to 1 for the other
// three, and try_get returns int. §15.3.1: the initial count may be negative.
// §15.3.2 to §15.3.4: put adds keys, get waits until the keys it asks for are
// there and takes them, try_get takes them only if they are there and then
// returns a positive integer, else 0.
//
// The test names the class as std::semaphore. It checks each default by
// counting what is left with try_get calls that ask for an explicit count;
// new(-1) followed by put(2) leaves exactly one key, which only a signed
// count gives. get(2) is started on an empty semaphore and returns only at
// time 10, after the second single key is put: a task that blocks. The
// function take_one calls put and try_get, which a function may do only for
// functions (13.4), and $typename, which does not evaluate the call (20.6.1),
// gives the result type of try_get. Only whether try_get returned a positive
// value is printed, since its value is not fixed. Each call is a statement of
// its own, so no order of evaluation within an expression matters. Icarus
// Verilog 13.0 does not know the std::semaphore type.

`timescale 1ns/1ns

module test_std_semaphore_prototype_defaults;
  std::semaphore s_def, s_one, s_neg, s_put, s_get, s_try, s_wait, s_fn;
  bit a, b, c;

  function automatic int take_one(std::semaphore s);
    s.put();
    return s.try_get();
  endfunction

  initial begin
    s_def = new;
    s_one = new(1);
    a = s_def.try_get(1) > 0;
    b = s_one.try_get(1) > 0;
    $display("new: default then try_get(1)>0 %0d, new(1) then try_get(1)>0 %0d", a, b);
    s_neg = new(-1);
    s_neg.put(2);
    a = s_neg.try_get(1) > 0;
    b = s_neg.try_get(1) > 0;
    $display("new(-1), put(2): try_get(1)>0 %0d, again %0d", a, b);
    s_put = new(0);
    s_put.put();
    a = s_put.try_get(2) > 0;
    b = s_put.try_get(1) > 0;
    c = s_put.try_get(1) > 0;
    $display("new(0), put(): try_get(2)>0 %0d, try_get(1)>0 %0d, again %0d", a, b, c);
    s_get = new(2);
    s_get.get();
    a = s_get.try_get(2) > 0;
    b = s_get.try_get(1) > 0;
    c = s_get.try_get(1) > 0;
    $display("new(2), get(): try_get(2)>0 %0d, try_get(1)>0 %0d, again %0d", a, b, c);
    s_try = new(2);
    a = s_try.try_get() > 0;
    b = s_try.try_get(2) > 0;
    c = s_try.try_get(1) > 0;
    $display("new(2), try_get()>0 %0d, then try_get(2)>0 %0d, try_get(1)>0 %0d", a, b, c);
    s_fn = new(0);
    a = take_one(s_fn) > 0;
    $display("function take_one: %0d, try_get returns %s", a, $typename(s_fn.try_get()));
    s_wait = new(0);
    fork
      begin
        s_wait.get(2);
        $display("%0t: get(2) returned", $time);
      end
    join_none
    #5 s_wait.put();
    $display("%0t: one key put", $time);
    #5 s_wait.put();
    #1 a = s_wait.try_get(1) > 0;
    $display("%0t: try_get(1)>0 %0d", $time, a);
  end
endmodule
