/*
:name: test_specify_edge_sensitive_path
:description: An edge-sensitive module path from posedge clk delays the output changes that the clock edge causes (IEEE 1800-2023 Section 30.4.3)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.4.3 30.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_edge_sensitive_path.expected
*/
// IEEE 1800-2023 §30.4.3: (posedge clk => (q +: d)) is a module path that is
// active only on a rising edge of clk; the data source d describes the flow of
// data but does not change propagation. With delays (4, 6) (30.5.1), q rises 4
// and falls 6 time units after the clock edge that loads a new value. Changes of
// d alone do not change q. Transitions before time 10 are not printed.

`timescale 1ns/1ns

module specify_edge_ff(output q, input clk, input d);
  reg qi = 0;
  always @(posedge clk) qi <= d;
  buf (q, qi);
  specify
    (posedge clk => (q +: d)) = (4, 6);
  endspecify
endmodule

module test_specify_edge_sensitive_path;
  reg clk = 0, d = 0;
  wire q;

  specify_edge_ff u(q, clk, d);

  always @(q) if ($time >= 10) $display("%0d: q=%b", $time, q);

  initial begin
    #5 d = 1;
    #5 clk = 1;     // 10: loads 1
    #5 clk = 0;
    d = 0;
    #5 clk = 1;     // 20: loads 0
    #5 clk = 0;
    #10 $finish;
  end
endmodule
