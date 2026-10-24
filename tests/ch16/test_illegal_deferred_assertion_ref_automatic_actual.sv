/*
:name: test_illegal_deferred_assertion_ref_automatic_actual
:description: an automatic variable cannot be passed to a ref argument of the subroutine of a deferred assertion (IEEE 1800-2023 Section 16.4)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the pass action of d2 passes the automatic variable k to the ref argument of show
:expected_stderr_regex: test_illegal_deferred_assertion_ref_automatic_actual\.sv:35:
*/
// IEEE 1800-2023 §16.4: it shall be an error to pass automatic or dynamic
// variables as actuals to a ref or const ref formal of the subroutine in an
// action of a deferred assertion, as that subroutine runs later in the time
// step. d0 passes the static variable s by reference, and d1 passes the
// automatic variable k by value; d2 passes k by reference.
// Icarus Verilog 13.0 does not support deferred assertions, and Verilator
// 5.052 accepts the design.

module test_illegal_deferred_assertion_ref_automatic_actual;
  logic a = 1;
  int s = 1;
  task automatic show(ref int x);
    $display("ref %0d", x);
  endtask
  function automatic void show_in(input int v);
    $display("in %0d", v);
  endfunction
  initial begin
    automatic int k = 2;
    d0: assert #0 (a) show(s);
    d1: assert #0 (a) show_in(k);
    d2: assert #0 (a) show(k);   // illegal
  end
endmodule
