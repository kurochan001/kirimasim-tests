/*
:name: test_illegal_attached_call_local_variable_before_assignment
:description: a local variable in an attached call has to be assigned before the call in the list or flow out of the sequence (IEEE 1800-2023 Section 16.11)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the call f_in(k) in p_bad comes before the assignment k = d in the list, and k does not flow out of a
:expected_stderr_regex: test_illegal_attached_call_local_variable_before_assignment\.sv:(43|47):
*/
// IEEE 1800-2023 §16.11: a local variable may be used in an actual argument
// of a call attached to a sequence if it flows out of the sequence or is
// assigned in the list before the call, and an argument with a local
// variable shall be passed by value. p_ok passes k by value after assigning
// it in the list, and p_flow passes k, which flows out of the sequence.
// p_bad calls f_in(k) before the assignment of k in the same list.
// A tool can report the error in p_bad or at its assertion a_bad.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 accepts the design.

module test_illegal_attached_call_local_variable_before_assignment;
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
    (a, f_in(k), k = d) |-> b;   // illegal
  endproperty
  a_ok: assert property (@(posedge clk) p_ok);
  a_flow: assert property (@(posedge clk) p_flow);
  a_bad: assert property (@(posedge clk) p_bad);
endmodule
