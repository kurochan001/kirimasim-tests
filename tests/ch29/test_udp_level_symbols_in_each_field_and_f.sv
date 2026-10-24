/*
:name: test_udp_level_symbols_in_each_field_and_f
:description: the UDP table symbols 0, 1 and x stand for logic 0, 1 and unknown in the input and output fields of combinational and sequential UDPs and in the current state field, and f is the same as (10) (IEEE 1800-2023 Section 29.3.6)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.3.6 29.3.4 29.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_level_symbols_in_each_field_and_f.expected
*/
// IEEE 1800-2023 §29.3.6, Table 29-1: the symbols 0, 1 and x stand for
// logic 0, logic 1 and unknown, and are allowed in the input and output
// fields of all UDPs and in the current state field of sequential UDPs; f
// is a falling edge, the same as (10). inv uses them in a combinational
// table: 0 gives 1, 1 gives 0 and x gives x. In sel, a rising edge of c
// gives a next state chosen by the input d and the current state (29.3.4):
// d 0 with state 0, 1 and x gives 1, 0 and 1, d 1 gives x, and d x gives 0;
// falling edges of c and changes of d keep the state, which starts at 0.
// ff_f and ff_10 differ only in f against (10): a rising edge gives 1 and
// a falling edge 0, and the changes from 1 to x and from x to 0, which
// neither f nor (10) includes, give x as no entry matches (29.6).

primitive inv(y, a);
  output y;
  input a;
  table
    0 : 1;
    1 : 0;
    x : x;
  endtable
endprimitive

primitive sel(q, c, d);
  output q;
  reg q;
  input c, d;
  initial q = 0;
  table
  // c    d : q : q+
    (01)  0 : 0 : 1;
    (01)  0 : 1 : 0;
    (01)  0 : x : 1;
    (01)  1 : ? : x;
    (01)  x : ? : 0;
    (10)  ? : ? : -;
    (x0)  ? : ? : -;
     ?  (??) : ? : -;
  endtable
endprimitive

primitive ff_f(q, c);
  output q;
  reg q;
  input c;
  table
    r : ? : 1;
    f : ? : 0;
  endtable
endprimitive

primitive ff_10(q, c);
  output q;
  reg q;
  input c;
  table
    r : ? : 1;
    (10) : ? : 0;
  endtable
endprimitive

module test_udp_level_symbols_in_each_field_and_f;
  logic a, c, d, k;
  wire y, q, qf, q10;
  inv u_inv(y, a);
  sel u_sel(q, c, d);
  ff_f u_f(qf, k);
  ff_10 u_10(q10, k);
  logic a_vals[3] = '{1'b0, 1'b1, 1'bx};

  task automatic rise(input logic dv);
    d = dv;
    #1 c = 1'b1;
    #1 $display("sel: rising c with d=%b: q=%b", d, q);
    c = 1'b0;
    #1;
  endtask

  task automatic step_k(input logic kv);
    k = kv;
    #1 $display("k=%b: ff_f=%b ff_10=%b", k, qf, q10);
  endtask

  initial begin
    foreach (a_vals[i]) begin
      a = a_vals[i];
      #1 $display("inv: a=%b y=%b", a, y);
    end
    c = 1'b0;
    d = 1'b0;
    #1;
    rise(1'b0);
    rise(1'b0);
    rise(1'b1);
    rise(1'b0);
    rise(1'bx);
    k = 1'b0;
    #1;
    step_k(1'b1);
    step_k(1'b0);
    step_k(1'b1);
    step_k(1'bx);
    step_k(1'b0);
    step_k(1'b1);
    step_k(1'b0);
  end

endmodule
