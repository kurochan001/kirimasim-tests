/*
:name: test_assertion_dist_as_inside
:description: in an assert or cover property, an expression with dist is true exactly when its value is in the set of the distribution, like inside, and the weights, a weight of zero included, are ignored; an assume property may also use dist (IEEE 1800-2023 Section 16.14.2)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.2 18.5.3 11.4.13 16.14.1 16.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assertion_dist_as_inside.expected
*/
// IEEE 1800-2023 §16.14.2: an assumption may use expression dist {...} to
// bias random simulation; in an assert or cover statement the dist operator
// is the same as inside (§11.4.13) and its weights are ignored. The
// distribution {0 := 0, [2:3] :/ 5, 6 := 2} (§18.5.3) has the values 0, 2, 3
// and 6; 0 has weight zero, which does not take it out of the set. v takes
// the values 0 to 7 at the ticks 5 to 75, so the assert and the reference
// assertion with inside pass at 5, 25, 35 and 65 and fail at the other ticks,
// and the cover property succeeds at the same four ticks. The assume
// property with dist {0 := 1, [2:3] :/ 5, 6 := 2}, the same set, is checked
// in simulation like the assertion. The action blocks (§16.14.1, §16.14.3)
// record the times. Icarus Verilog 13.0 does not support these assertions.
// The 5.052 release of Verilator differs from the standard: its assert with
// dist fails at 5, as if the weight of zero removed 0 from the set, and its
// cover property with dist never succeeds.

`timescale 1ns/1ns

module test_assertion_dist_as_inside;
  logic clk = 0;
  logic [2:0] v = 0;
  int p_dist[$], f_dist[$], p_in[$], f_in[$], c_dist[$], p_asm[$], f_asm[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_dist: assert property (@(posedge clk) v dist {3'd0 := 0, [3'd2:3'd3] :/ 5, 3'd6 := 2})
    p_dist.push_back($time); else f_dist.push_back($time);
  a_in: assert property (@(posedge clk) v inside {3'd0, [3'd2:3'd3], 3'd6})
    p_in.push_back($time); else f_in.push_back($time);
  c_cov: cover property (@(posedge clk) v dist {3'd0 := 0, [3'd2:3'd3] :/ 5, 3'd6 := 2})
    c_dist.push_back($time);
  u_asm: assume property (@(posedge clk) v dist {3'd0 := 1, [3'd2:3'd3] :/ 5, 3'd6 := 2})
    p_asm.push_back($time); else f_asm.push_back($time);

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    for (int i = 0; i < 8; i++) begin
      v = i;   // sampled at the tick 10 * i + 5
      #10;
    end
    $display("assert dist: passes%s; failures%s", times(p_dist), times(f_dist));
    $display("assert inside: passes%s; failures%s", times(p_in), times(f_in));
    $display("cover dist:%s", times(c_dist));
    $display("assume dist: passes%s; failures%s", times(p_asm), times(f_asm));
    $finish;
  end
endmodule
