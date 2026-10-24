/*
:name: test_udp_symbol_uppercase_forms
:description: the UDP table symbols X, B, R, F, P and N, and X inside parenthesized value changes, mean the same as x, b, r, f, p and n (IEEE 1800-2023 Section 29.3)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.3 29.3.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_symbol_uppercase_forms.expected
*/
// IEEE 1800-2023 §29.3, Syntax 29-1: the level symbols are 0, 1, x, X, ?, b
// and B, the edge symbols r, R, f, F, p, P, n, N and *, a parenthesized
// value change is made of two level symbols, and an output symbol is 0, 1,
// x or X; Table 29-1 (29.3.6) gives the meaning of each symbol. Each pair
// of UDPs below has the same table, once with lowercase symbols and once
// with uppercase ones: lv uses x and b in input fields and x in the output
// field, ed r and f with b data, po p and n, and vc the value changes (bx)
// and (x?), written (bX) and (X?) in the uppercase table. Both UDPs of a
// pair get the same inputs, and the outputs of both are printed after each
// change.

primitive lv_lo(y, a, b);
  output y;
  input a, b;
  table
    x b : 1;
    b x : 0;
    x x : x;
  endtable
endprimitive

primitive lv_up(y, a, b);
  output y;
  input a, b;
  table
    X B : 1;
    B X : 0;
    X X : X;
  endtable
endprimitive

primitive ed_lo(q, c, d);
  output q;
  reg q;
  input c, d;
  table
    r b : ? : 1;
    f b : ? : 0;
    ? * : ? : -;
  endtable
endprimitive

primitive ed_up(q, c, d);
  output q;
  reg q;
  input c, d;
  table
    R B : ? : 1;
    F B : ? : 0;
    ? * : ? : -;
  endtable
endprimitive

primitive po_lo(q, c);
  output q;
  reg q;
  input c;
  table
    p : ? : 1;
    n : ? : 0;
  endtable
endprimitive

primitive po_up(q, c);
  output q;
  reg q;
  input c;
  table
    P : ? : 1;
    N : ? : 0;
  endtable
endprimitive

primitive vc_lo(q, c);
  output q;
  reg q;
  input c;
  table
    (bx) : ? : 1;
    (x?) : ? : 0;
  endtable
endprimitive

primitive vc_up(q, c);
  output q;
  reg q;
  input c;
  table
    (bX) : ? : 1;
    (X?) : ? : 0;
  endtable
endprimitive

module test_udp_symbol_uppercase_forms;
  logic a, b, c, d, k;
  wire y_lo, y_up, e_lo, e_up, p_lo, p_up, v_lo, v_up;
  lv_lo g1(y_lo, a, b);
  lv_up g2(y_up, a, b);
  ed_lo g3(e_lo, c, d);
  ed_up g4(e_up, c, d);
  po_lo g5(p_lo, k);
  po_up g6(p_up, k);
  vc_lo g7(v_lo, k);
  vc_up g8(v_up, k);

  logic vals[3] = '{1'b0, 1'b1, 1'bx};

  task automatic clock(input logic cv);
    c = cv;
    #1 $display("ed: c=%b d=%b: lower=%b upper=%b", c, d, e_lo, e_up);
  endtask

  task automatic step(input logic kv);
    k = kv;
    #1 $display("k=%b: po lower=%b upper=%b, vc lower=%b upper=%b", k, p_lo, p_up, v_lo, v_up);
  endtask

  initial begin
    for (int i = 0; i < 3; i++)
      for (int j = 0; j < 3; j++) begin
        a = vals[i];
        b = vals[j];
        #1 $display("lv: a=%b b=%b: lower=%b upper=%b", a, b, y_lo, y_up);
      end
    c = 1'b0;
    d = 1'b0;
    #1;
    clock(1'b1);
    clock(1'b0);
    d = 1'b1;
    #1;
    clock(1'b1);
    clock(1'b0);
    d = 1'bx;
    #1;
    clock(1'b1);
    k = 1'b0;
    #1;
    step(1'bx);
    step(1'b0);
    step(1'b1);
    step(1'bx);
    step(1'b1);
    step(1'b0);
  end
endmodule
