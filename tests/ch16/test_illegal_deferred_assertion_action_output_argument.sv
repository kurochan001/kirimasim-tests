/*
:name: test_illegal_deferred_assertion_action_output_argument
:description: an argument of the subroutine called by a deferred assertion cannot be an output argument (IEEE 1800-2023 Section 16.4)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the fail action of d3 calls the task t_out, whose argument o is an output
:expected_stderr_regex: test_illegal_deferred_assertion_action_output_argument\.sv:41:
*/
// IEEE 1800-2023 §16.4: an argument of the subroutine in an action of a
// deferred assertion may be passed by value as an input, or by reference as
// a ref or const ref; no other direction is allowed. d0, d1 and d2 pass the
// static variable r to an input, a ref and a const ref argument; d3 passes
// it to the output argument of t_out.
// Icarus Verilog 13.0 does not support deferred assertions, and Verilator
// 5.052 accepts the design.

module test_illegal_deferred_assertion_action_output_argument;
  logic a = 1;
  int r = 4;
  function automatic void f_in(input int v);
    $display("in %0d", v);
  endfunction
  task automatic t_ref(ref int x);
    $display("ref %0d", x);
  endtask
  function automatic void f_cref(const ref int x);
    $display("const ref %0d", x);
  endfunction
  task automatic t_out(output int o);
    o = 1;
  endtask
  initial begin
    d0: assert #0 (a) f_in(r);
    d1: assert #0 (a) t_ref(r);
    d2: assert #0 (a) f_cref(r);
    d3: assert #0 (a) else t_out(r);   // illegal
  end
endmodule
