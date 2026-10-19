/*
:name: test_resistive_switch_supply_reduction
:description: Resistive switches reduce a supply drive to a pull drive (IEEE 1800-2023 Section 28.14)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.14 28.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_resistive_switch_supply_reduction.expected
*/
// IEEE 1800-2023 §28.14: rnmos, rpmos, rcmos, rtran, rtranif1 and rtranif0
// lower the strength of what passes through them, and supply and strong drives
// both become pull drives. So a supply 1 through such a switch, against a pull 0
// on the same net, gives x (equal strengths with different values, 28.12.1); it
// beats a weak 0 and loses to a strong 0.

module test_resistive_switch_supply_reduction;
  wire s1; assign (supply0, supply1) s1 = 1'b1;
  wire s0; assign (supply0, supply1) s0 = 1'b0;
  wire w1; assign (strong0, strong1) w1 = 1'b1;
  wire a;  rnmos   g_a (a, s1, 1'b1);       assign (pull0, pull1) a = 1'b0;  // A: pull1 vs pull0 = x
  wire b;  rpmos   g_b (b, s0, 1'b0);       assign (pull0, pull1) b = 1'b1;  // B: pull0 vs pull1 = x
  wire c;  rcmos   g_c (c, s1, 1'b1, 1'b0); assign (pull0, pull1) c = 1'b0;  // C: x
  wire sd; assign (supply0, supply1) sd = 1'b1;
  wire d;  rtran   g_d (sd, d);             assign (pull0, pull1) d = 1'b0;  // D: x
  wire se; assign (supply0, supply1) se = 1'b1;
  wire e;  rtranif1 g_e (se, e, 1'b1);      assign (pull0, pull1) e = 1'b0;  // E: x
  wire k1; rnmos   g_k1 (k1, w1, 1'b1);     assign (pull0, pull1) k1 = 1'b0; // control: strong becomes pull = x
  wire k2; rnmos   g_k2 (k2, s1, 1'b1);     assign (weak0, weak1) k2 = 1'b0; // control: pull beats weak = 1
  wire k3; rnmos   g_k3 (k3, s1, 1'b1);     assign k3 = 1'b0;                // F: pull loses to strong = 0
  int errors = 0;

  task automatic check(string what, logic got, logic exp);
    if (got !== exp) begin
      $display("WRONG %s = %b, expected %b", what, got, exp);
      errors++;
    end
  endtask

  initial begin
    #1;
    check("A rnmos supply1 vs pull0", a, 1'bx);
    check("B rpmos supply0 vs pull1", b, 1'bx);
    check("C rcmos supply1 vs pull0", c, 1'bx);
    check("D rtran supply1 vs pull0", d, 1'bx);
    check("E rtranif1 supply1 vs pull0", e, 1'bx);
    check("ctl strong through rnmos vs pull0", k1, 1'bx);
    check("ctl supply through rnmos vs weak0", k2, 1'b1);
    check("F supply through rnmos vs strong0", k3, 1'b0);
    if (errors == 0) begin
      $display("TEST PASSED: resistive switches reduce supply to pull");
    end else begin
      $display("TEST FAILED: %0d errors", errors);
    end
    $finish;
  end
endmodule
