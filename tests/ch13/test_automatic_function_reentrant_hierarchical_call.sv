/*
:name: test_automatic_function_reentrant_hierarchical_call
:description: Each call of a recursive automatic function keeps its own argument and local variables, and a call of the function through its hierarchical name from another module gives the same results as a call in its own module (IEEE 1800-2023 Section 13.4.2)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.2
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_automatic_function_reentrant_hierarchical_call.expected
*/
// IEEE 1800-2023 §13.4.2: an automatic function is reentrant: the items it
// declares are allocated anew for each call, so a recursive call does not
// overwrite the argument and the locals of the call that made it. An
// automatic function can also be called through its hierarchical name.
//
// In the module auto_math, fact saves its argument n in the local here before
// it calls itself, and multiplies here by the result of that call only after
// it returns; fib calls itself twice in separate statements, so its second
// call uses n and its local a after the first call has returned. With one
// shared copy of n, here and a, the inner calls would leave them at the
// values of the deepest call, and fact(5) would give 1 instead of 120.
// auto_math calls both functions itself and keeps the results in local_fact
// and local_fib; the top module reads them one time unit later and calls the
// same functions as u.fact and u.fib, which give the same values.

module auto_math;
  int local_fact, local_fib;

  function automatic int fact(input int n);
    int here, below;
    here = n;
    if (n <= 1) return 1;
    below = fact(n - 1);
    return here * below;
  endfunction

  function automatic int fib(input int n);
    int a, b;
    if (n < 2) return n;
    a = fib(n - 1);
    b = fib(n - 2);
    return a + b;
  endfunction

  initial begin
    local_fact = fact(5);
    local_fib = fib(10);
  end
endmodule

module test_automatic_function_reentrant_hierarchical_call;
  auto_math u ();

  initial begin
    #1;
    $display("local: fact(5)=%0d fib(10)=%0d", u.local_fact, u.local_fib);
    $display("hierarchical: fact(5)=%0d fib(10)=%0d", u.fact(5), u.fib(10));
    $display("hierarchical: fact(1)=%0d fact(7)=%0d", u.fact(1), u.fact(7));
  end
endmodule
