/*
:name: test_gate_delay_independent_of_input_strength
:description: buf and nmos gates with the same delays change their outputs at the same times whether their inputs are driven with supply, strong, pull or weak strength (IEEE 1800-2023 Section 28.16)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.16 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_gate_delay_independent_of_input_strength.expected
*/
// IEEE 1800-2023 §28.16: the strength of an input signal does not affect the
// propagation delay from that input to the output. Four nets carry the
// variable v with supply, strong, pull and weak strength, and each feeds a
// buf #(3,5) and an nmos #(3,5) that is on. v goes through the changes
// between 0, 1 and x, 20 time units apart; the rise delay 3 applies to a
// change to 1, the fall delay 5 to a change to 0 and the smaller, 3, to a
// change to x. For every output an always procedure records the time of
// its last change, and 19 time units after each change of v the delay since
// that change is printed for all eight outputs, and the nmos outputs, which
// keep the strength of their input except supply (28.13), with %v
// (21.2.1.4).

`timescale 1ns/1ns
module test_gate_delay_independent_of_input_strength;
  logic v;
  wire s_su, s_st, s_pu, s_we;
  assign (supply0, supply1) s_su = v;
  assign (strong0, strong1) s_st = v;
  assign (pull0, pull1) s_pu = v;
  assign (weak0, weak1) s_we = v;

  wire b_su, b_st, b_pu, b_we, n_su, n_st, n_pu, n_we;
  buf #(3, 5) gb_su(b_su, s_su);
  buf #(3, 5) gb_st(b_st, s_st);
  buf #(3, 5) gb_pu(b_pu, s_pu);
  buf #(3, 5) gb_we(b_we, s_we);
  nmos #(3, 5) gn_su(n_su, s_su, 1'b1);
  nmos #(3, 5) gn_st(n_st, s_st, 1'b1);
  nmos #(3, 5) gn_pu(n_pu, s_pu, 1'b1);
  nmos #(3, 5) gn_we(n_we, s_we, 1'b1);

  time tb[4], tn[4];
  always @(b_su) tb[0] = $time;
  always @(b_st) tb[1] = $time;
  always @(b_pu) tb[2] = $time;
  always @(b_we) tb[3] = $time;
  always @(n_su) tn[0] = $time;
  always @(n_st) tn[1] = $time;
  always @(n_pu) tn[2] = $time;
  always @(n_we) tn[3] = $time;

  task automatic step(string what, logic nv);
    time t;
    v = nv;
    t = $time;
    #19;
    $display("%s buf: supply=+%0d strong=+%0d pull=+%0d weak=+%0d", what,
             tb[0] - t, tb[1] - t, tb[2] - t, tb[3] - t);
    $display("%s nmos: supply=+%0d %v strong=+%0d %v pull=+%0d %v weak=+%0d %v", what,
             tn[0] - t, n_su, tn[1] - t, n_st, tn[2] - t, n_pu, tn[3] - t, n_we);
    #1;
  endtask

  initial begin
    v = 1'b0;
    #20;
    step("0->1", 1'b1);
    step("1->0", 1'b0);
    step("0->x", 1'bx);
    step("x->1", 1'b1);
    step("1->x", 1'bx);
    step("x->0", 1'b0);
  end
endmodule
