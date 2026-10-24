/*
:name: test_udp_uppercase_b_in_value_change
:description: the level symbol B inside a parenthesized value change of a UDP table, as in (BX) and (B1), means the same as b (IEEE 1800-2023 Section 29.3)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.3 29.3.6
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_uppercase_b_in_value_change.expected
*/
// IEEE 1800-2023 §29.3, Syntax 29-1: a parenthesized value change is made of
// two level symbols, and B is a level symbol with the meaning of b, 0 or 1
// (Table 29-1 in 29.3.6). vc_lo and vc_up have the same table, with (bx)
// and (b1) in the first and (BX) and (B1) in the second: a change from 0 or
// 1 to x gives 0, and a change from 0 or 1 to 1, which can only be from 0,
// gives 1. A change from x gives x, as no entry matches. Both get the same
// input, and both outputs are printed after each change.
// Icarus Verilog 13.0 rejects B inside a value change (a syntax error).

primitive vc_lo(q, c);
  output q;
  reg q;
  input c;
  table
    (bx) : ? : 0;
    (b1) : ? : 1;
  endtable
endprimitive

primitive vc_up(q, c);
  output q;
  reg q;
  input c;
  table
    (BX) : ? : 0;
    (B1) : ? : 1;
  endtable
endprimitive

module test_udp_uppercase_b_in_value_change;
  logic k;
  wire v_lo, v_up;
  vc_lo g1(v_lo, k);
  vc_up g2(v_up, k);

  task automatic step(input logic kv);
    k = kv;
    #1 $display("k=%b: lower=%b upper=%b", k, v_lo, v_up);
  endtask

  initial begin
    k = 1'b0;
    #1;
    step(1'b1);
    step(1'bx);
    step(1'b0);
    step(1'bx);
    step(1'b1);
  end
endmodule
