/*
:name: test_illegal_attached_call_inout_argument
:description: an argument of a subroutine call attached to a sequence cannot be an inout argument (IEEE 1800-2023 Section 16.11)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the task t_io attached to the sequence of a_bad has the inout argument io
:expected_stderr_regex: test_illegal_attached_call_inout_argument\.sv:41:
*/
// IEEE 1800-2023 §16.11: each argument of a subroutine call attached to a
// sequence shall be passed by value as an input or by reference as ref or
// const ref, and a variable passed by value shall be of a type allowed in
// assertions (16.6). a_in, a_ref and a_cref attach calls that pass the
// static variable d to an input, a ref and a const ref argument.
// a_bad attaches the task t_io, whose argument io is an inout.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 accepts the design.

module test_illegal_attached_call_inout_argument;
  logic clk = 0, a = 0, b = 0;
  int d = 0;
  task automatic t_io(inout int io);
    io = io + 1;
  endtask
  function automatic void f_in(input int v);
    $display("in %0d", v);
  endfunction
  task automatic t_ref(ref int x);
    $display("ref %0d", x);
  endtask
  function automatic void f_cref(const ref int x);
    $display("const ref %0d", x);
  endfunction
  a_in: assert property (@(posedge clk) (a, f_in(d)) |-> b);
  a_ref: assert property (@(posedge clk) (a, t_ref(d)) |-> b);
  a_cref: assert property (@(posedge clk) (a, f_cref(d)) |-> b);
  a_bad: assert property (@(posedge clk) (a, t_io(d)) |-> b);   // illegal
endmodule
