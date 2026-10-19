/*
:name: test_assignment_like_contexts
:description: untyped assignment patterns and unpacked array concatenations take their type from an assignment-like context: a typed parameter, a parameter override, an input port connection, a subroutine argument, a return statement, the operands of ?: and a static cast (IEEE 1800-2023 Section 10.8)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.8 10.9 10.10 6.24.1 13.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assignment_like_contexts.expected
*/
// IEEE 1800-2023 §10.8: assignment-like contexts are assignments, a value of
// a parameter with an explicit type and its override in an instantiation, a
// connection to an input port, a value passed to a subroutine input, a return
// statement, the second and third operands of a conditional operator in such
// a context, and a static cast (§6.24.1). In them an assignment pattern
// without a type (§10.9) and an unpacked array concatenation (§10.10) take
// the type of the target. pair_t is a struct of two ints; the function
// returns its argument with the members swapped (§13.4.1). Each instance of
// show_pair prints after a delay of P.a, so u1 prints before u2.

typedef struct { int a, b; } pair_t;

module show_pair #(parameter pair_t P = '{1, 2}) (input pair_t in);
  initial #(P.a) $display("%m: P = %0d %0d, in = %0d %0d", P.a, P.b, in.a, in.b);
endmodule

module test_assignment_like_contexts;
  pair_t p;
  int sum;
  bit c = 1;

  function automatic pair_t swap(pair_t x);
    return '{x.b, x.a};
  endfunction

  function automatic int total(int q[$]);
    total = 0;
    foreach (q[i]) total += q[i];
  endfunction

  function automatic int unsigned count3();
    int r[$];
    r = {total({1, 2}), 3, 4};
    return r.size();
  endfunction

  show_pair u1('{3, 4});
  show_pair #(.P('{5, 6})) u2(.in('{7, 8}));

  initial begin
    p = swap('{10, 20});
    $display("swap: %0d %0d", p.a, p.b);
    p = c ? '{1, 1} : '{2, 2};
    $display("?: %0d %0d", p.a, p.b);
    p = pair_t'('{30, 40});
    $display("cast: %0d %0d", p.a, p.b);
    sum = total({1, 2, 3, 4});
    $display("total({1, 2, 3, 4}) = %0d, count3() = %0d", sum, count3());
  end
endmodule
