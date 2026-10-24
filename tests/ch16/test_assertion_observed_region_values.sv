/*
:name: test_assertion_observed_region_values
:description: a concurrent assertion triggered by a clock edge in the Active region is evaluated in the Observed region of the same time step, after nonblocking updates, with the sampled values of its property and sequence expressions but the current values of its disable condition and clocking event; the keyword property makes an assertion in a procedure concurrent instead of immediate (IEEE 1800-2023 Sections 16.5, 16.5.2, 16.6)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.5 16.5.2 16.6 16.12 16.14.1 16.14.3 16.14.6 16.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assertion_observed_region_values.expected
*/
// IEEE 1800-2023 §16.5: concurrent assertions are evaluated in the Observed
// region and use the sampled values of their expressions, except for the
// disable condition (§16.12) and the clocking event, which use current
// values. §16.5.2: a clock edge in the Active region makes the assertion
// evaluate in the Observed region of that time step. §16.6: the Boolean
// expressions of sequences and properties use sampled values, the clocking
// event does not.
// clk rises at 10, 20, 30 and 40. At 10 the procedure raises clk and makes
// the nonblocking assignments d <= 1 and x <= 1, which take effect in the NBA
// region, before the Observed region; d is cleared at 15 and x at 20, again
// by a nonblocking assignment. a_dis, whose property 1'b0 always fails, is
// disabled at 10 by the current d, and fails at 20, 30 and 40; with sampled
// values, or an evaluation at the edge itself, it would fail at 10 as well.
// a_smp and c_seq see x sampled as 0, 1, 0, 0, not the current 1, 0, 0, 0.
// a_clk is clocked by posedge clk iff g: g is set just before the edge at 30
// and cleared just before the edge at 40, so the current g gives a tick at
// 30 only, while the sampled g would give one at 40 only.
// §16.5.2 (and §16.3, §16.14.6): the keyword property makes an assertion
// concurrent. In an always procedure that inverts w at each rising edge of
// clk, the immediate assert (w) sees the new w, while assert property (w)
// takes the clock of the procedure and sees the sampled w, the value from
// before the edge. The action blocks (§16.14.1, §16.14.3) record the times.
// With Verilator 5.052, a_dis also fails at 10: its disable condition does
// not see the value that the NBA region gives d before the Observed region.

`timescale 1ns/1ns

module test_assertion_observed_region_values;
  logic clk = 0, d = 0, x = 0, g = 0, w = 0;
  int f_dis[$], p_smp[$], f_smp[$], m_seq[$], t_clk[$], p_imm[$], f_imm[$], p_con[$], f_con[$];

  a_dis: assert property (@(posedge clk) disable iff (d) 1'b0) else f_dis.push_back($time);
  a_smp: assert property (@(posedge clk) x == 0) p_smp.push_back($time);
    else f_smp.push_back($time);
  c_seq: cover sequence (@(posedge clk) x == 0 ##1 x == 1) m_seq.push_back($time);
  a_clk: cover property (@(posedge clk iff g) 1'b1) t_clk.push_back($time);

  always @(posedge clk) begin
    w = ~w;
    a_imm: assert (w) p_imm.push_back($time); else f_imm.push_back($time);
    a_con: assert property (w) p_con.push_back($time); else f_con.push_back($time);
  end

  function automatic string times(int t[$]);
    string str = "";
    foreach (t[i]) str = {str, $sformatf(" %0d", t[i])};
    return str;
  endfunction

  initial begin
    #10 clk = 1;
    d <= 1;
    x <= 1;
    #5 clk = 0;    // 15
    d = 0;
    #5 clk = 1;    // 20
    x <= 0;
    #5 clk = 0;    // 25
    #5 g = 1;      // 30
    clk = 1;
    #5 clk = 0;    // 35
    #5 g = 0;      // 40
    clk = 1;
    #5 clk = 0;    // 45
    #5;
    $display("a_dis: failures%s", times(f_dis));
    $display("a_smp x == 0: passes%s, failures%s", times(p_smp), times(f_smp));
    $display("c_seq x == 0 ##1 x == 1: matches%s", times(m_seq));
    $display("a_clk posedge clk iff g: ticks%s", times(t_clk));
    $display("assert (w): passes%s, failures%s", times(p_imm), times(f_imm));
    $display("assert property (w): passes%s, failures%s", times(p_con), times(f_con));
    $finish;
  end
endmodule
