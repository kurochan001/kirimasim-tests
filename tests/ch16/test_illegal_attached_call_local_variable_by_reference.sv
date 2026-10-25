/*
:name: test_illegal_attached_call_local_variable_by_reference
:description: a local variable in an argument of an attached call has to be passed by value (IEEE 1800-2023 Section 16.11)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the call t_ref(k) in p_bad passes the local variable k to a ref argument
:expected_stderr_regex: test_illegal_attached_call_local_variable_by_reference\.sv:(43|47):
*/
// IEEE 1800-2023 §16.11: a local variable may be used in an actual argument
// of a call attached to a sequence if it flows out of the sequence or is
// assigned in the list before the call, and an argument with a local
// variable shall be passed by value. p_ok passes k by value after assigning
// it in the list, and p_flow passes k, which flows out of the sequence.
// p_bad passes the assigned k to the ref argument of t_ref.
// A tool can report the error in p_bad or at its assertion a_bad.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 accepts the design.

module test_illegal_attached_call_local_variable_by_reference;
  logic clk = 0, a = 0, b = 0;
  int d = 0;
  function automatic void f_in(input int v);
    $display("in %0d", v);
  endfunction
  task automatic t_ref(ref int x);
    $display("ref %0d", x);
  endtask
  property p_ok;
    int k;
    (a, k = d, f_in(k)) |-> b;
  endproperty
  property p_flow;
    int k;
    (a, k = d) ##1 (b, f_in(k));
  endproperty
  property p_bad;
    int k;
    (a, k = d, t_ref(k)) |-> b;   // illegal
  endproperty
  a_ok: assert property (@(posedge clk) p_ok);
  a_flow: assert property (@(posedge clk) p_flow);
  a_bad: assert property (@(posedge clk) p_bad);
endmodule
