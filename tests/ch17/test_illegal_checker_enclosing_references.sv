/*
:name: test_illegal_checker_enclosing_references
:description: A checker cannot reference an automatic variable of its enclosing scope, an element of a dynamic variable, or an element of a fork-join block (IEEE 1800-2023 Section 17.2)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.2 6.21
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the checker references the automatic module variable auto_var, the queue element q[0], and the static fork-block variable f.fx
:expected_stderr_regex: test_illegal_checker_enclosing_references\.sv:(29|33|37):
*/
// IEEE 1800-2023 17.2: a checker shall not reference automatic variables
// from the scope enclosing the checker declaration, members or elements of
// dynamic variables, or elements of fork-join, fork-join_any or
// fork-join_none blocks. The module is automatic, so auto_var is automatic.
// The queue q is dynamic and q[0] is its element. The named fork block f has
// a static variable fx, so f.fx is an element of a fork-join block. Each of
// the three checkers reads one of these and is otherwise legal.
// Icarus Verilog 13.0 has no checkers and Verilator 5.052 accepts the design.

module automatic test_illegal_checker_enclosing_references;
  int auto_var = 3;
  int q[$];
  int o1, o2, o3;

  checker ref_auto(output int o);
    always_comb o = auto_var;   // illegal: enclosing automatic variable
  endchecker

  checker ref_dyn(output int o);
    always_comb o = q[0];       // illegal: element of a dynamic variable
  endchecker

  checker ref_fork(output int o);
    always_comb o = f.fx;       // illegal: element of a fork-join block
  endchecker

  ref_auto u1(o1);
  ref_dyn u2(o2);
  ref_fork u3(o3);

  initial begin
    q.push_back(5);
    fork : f
      static int fx = 7;
      #1;
    join
  end

  initial #2 $finish;
endmodule
