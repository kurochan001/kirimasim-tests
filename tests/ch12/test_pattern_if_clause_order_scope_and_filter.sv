/*
:name: test_pattern_if_clause_order_scope_and_filter
:description: an if predicate of &&& clauses is a left-to-right conjunction whose pattern identifiers reach later clauses and the true arm only (IEEE 1800-2023 Section 12.6.2)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.6.2 12.6
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_pattern_if_clause_order_scope_and_filter.expected
*/
// IEEE 1800-2023 §12.6.2: the predicate of an if statement can be clauses
// joined by &&&, each a Boolean filter or "expression matches pattern". The
// clauses are evaluated from left to right, a failing clause stops the
// evaluation of the rest, and the predicate is true only when every clause
// succeeds. The identifiers of a pattern are new variables (12.6) whose scope
// is the remaining clauses and the true arm, not the false arm. A pattern
// match always gives 0 or 1, but a Boolean filter can make the predicate x;
// the true arm runs only when the predicate is a known value other than 0.
// The module has its own n = 100, and each pattern binds a new n. chk() counts
// its calls and returns 1 when its first argument is below the second, so a
// filter chk(n, 10) is true for the bound n of 3 but false for the outer n.
// S3 fails on its first filter, so a right-to-left evaluation would call chk
// twice. S4 and S5 use an x and a z filter, S6 a two-bit filter of value 2.
// Icarus Verilog 13.0 does not support tagged unions, and Verilator 5.052
// does not support the &&& operator.

module test_pattern_if_clause_order_scope_and_filter;
  typedef union tagged {
    void None;
    int  Val;
  } opt_t;

  opt_t v;
  int n = 100;
  int calls;
  logic f1;
  logic [1:0] f2;

  function automatic bit chk(int x, int lim);
    calls++;
    return x < lim;
  endfunction

  initial begin
    v = tagged Val 3; calls = 0;
    if (v matches tagged Val .n &&& chk(n, 10) &&& chk(n, 5))
      $display("S1 true n=%0d calls=%0d", n, calls);
    else
      $display("S1 false n=%0d calls=%0d", n, calls);

    v = tagged None; calls = 0;
    if (v matches tagged Val .n &&& chk(n, 10))
      $display("S2 true n=%0d calls=%0d", n, calls);
    else
      $display("S2 false n=%0d calls=%0d", n, calls);

    v = tagged Val 7; calls = 0;
    if (v matches tagged Val .n &&& chk(n, 5) &&& chk(n, 10))
      $display("S3 true n=%0d calls=%0d", n, calls);
    else
      $display("S3 false n=%0d calls=%0d", n, calls);

    v = tagged Val 1; f1 = 1'bx;
    if (v matches tagged Val .n &&& f1)
      $display("S4 true n=%0d", n);
    else
      $display("S4 false n=%0d", n);

    f1 = 1'bz;
    if (v matches tagged Val .n &&& f1)
      $display("S5 true n=%0d", n);
    else
      $display("S5 false n=%0d", n);

    f2 = 2'b10;
    if (v matches tagged Val .n &&& f2)
      $display("S6 true n=%0d", n);
    else
      $display("S6 false n=%0d", n);

    $display("outer n=%0d", n);
  end
endmodule
