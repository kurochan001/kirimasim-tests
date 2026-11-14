/*
:name: test_function_const_ref_formals_in_restricted_contexts
:description: A function whose only formal arguments are const ref can be called in an event expression, in the expression of a force statement and in a continuous assignment, and each call gives the result of the function (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_const_ref_formals_in_restricted_contexts.expected
*/
// IEEE 1800-2023 §13.4: a function with output, inout or ref formal
// arguments cannot be called in an event expression, in an expression within
// a procedural continuous assignment, or in an expression that is not within
// a procedural statement, but const ref formal arguments are legal there.
// weigh has the two const ref formals x and y and returns x * 10 + y. It is
// called in all three places: the continuous assignment to cont_v, the force
// statement for forced_v (10.6: the forced expression is reevaluated when a
// variable in it changes) and the event control of the watching procedure
// (9.4.2: it wakes when the value of the expression changes).
// a and b start as 2 and 3, so both assignments give 23 and the watcher still
// waits at time 1. a becomes 4 at time 2: both give 43 at time 3, and the
// watcher has woken and computed 43. b becomes 7 at time 3, and both give 47
// at time 4. An implementation that rejected a const ref formal in one of the
// places would not compile the design.
// Icarus Verilog 13.0 does not parse const ref formals, and the 5.054 release
// of Verilator reports the call in the event control as an unsupported
// impure function call.

module test_function_const_ref_formals_in_restricted_contexts;
  int a = 2, b = 3;
  int cont_v, forced_v;
  bit woke = 0;
  int event_v = -1;

  function automatic int weigh(const ref int x, const ref int y);
    return x * 10 + y;
  endfunction

  assign cont_v = weigh(a, b);

  initial begin
    @(weigh(a, b));
    woke = 1;
    event_v = weigh(a, b);
  end

  initial begin
    force forced_v = weigh(a, b);
    #1 $display("start: continuous=%0d forced=%0d woke=%0d", cont_v, forced_v, woke);
    #1 a = 4;
    #1 $display("a=4: continuous=%0d forced=%0d woke=%0d event value=%0d", cont_v, forced_v,
                woke, event_v);
    b = 7;
    #1 $display("b=7: continuous=%0d forced=%0d", cont_v, forced_v);
  end
endmodule
