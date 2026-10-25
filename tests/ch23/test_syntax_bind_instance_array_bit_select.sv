/*
:name: test_syntax_bind_instance_array_bit_select
:description: An instance-target bind names one element of an array of instances with a constant bit-select and inserts the bound module into only that instance (IEEE 1800-2023 Section 23.11)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.11 A.1.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_bind_instance_array_bit_select.expected
*/
// IEEE 1800-2023 A.1.4: the second form of bind_directive is bind, a
// bind_target_instance and a bind_instantiation. A bind_target_instance is a
// hierarchical identifier with a constant bit-select, so an element of an
// array of instances can be named. The bound instance is inserted into that
// instance only (23.11), and its actual ports are names of the target.
//
// probe computes a + ID. One bind names t.larr[1] and gives ID 4, so only
// larr[1] is probed: its s is 13 while the s of larr[0] is left at 0. The
// printed a values show which instance of the array each line is about.
//
// Neither release accepts a hierarchical bind target: Icarus Verilog 13.0 has
// no bind at all and Verilator 5.052 stops at the dot of the target.

module probe #(parameter int ID = 0) (input var int sig, output int outp);
  assign outp = sig + ID;
endmodule

module biba_leaf;
  int a;
  int s;
endmodule

module test_syntax_bind_instance_array_bit_select;
  biba_leaf larr [2] ();

  bind test_syntax_bind_instance_array_bit_select.larr[1] probe #(.ID(4)) u_arr
      (.sig(a), .outp(s));

  initial begin
    larr[0].a = 3;
    larr[1].a = 9;
    #1 $display("element 0: a=%0d s=%0d", larr[0].a, larr[0].s);
    $display("element 1: a=%0d s=%0d", larr[1].a, larr[1].s);
  end
endmodule
