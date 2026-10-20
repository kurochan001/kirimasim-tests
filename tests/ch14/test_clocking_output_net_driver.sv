/*
:name: test_clocking_output_net_driver
:description: A clocking block output on a net drives it through a strong driver that starts at z, so the net shows its other drivers until the first drive, and the driven value is resolved with them (IEEE 1800-2023 Section 14.16)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.16 14.16.2 6.6.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_clocking_output_net_driver.expected
*/
// IEEE 1800-2023 §14.16: for a clocking output on a net, a driver with strong
// strength is created; it starts at z and changes only by synchronous drives.
// w also has a weak driver of 1. So w is 1 until the first drive, a driven 0
// wins over the weak 1, and driving z gives the net back to the weak driver.
// The net is resolved as its type says (14.16.2, 6.6.1); the wand net wa,
// driven to 1 by an assignment, becomes 0 when the clocking output drives 0.

module test_clocking_output_net_driver;
  logic clk = 0;
  wire w;
  wand wa;

  always #5 clk = ~clk;

  assign (weak0, weak1) w = 1'b1;
  assign wa = 1'b1;

  clocking cb @(posedge clk);
    output w, wa;
  endclocking

  initial begin
    #1 $display("t=%0d: w=%b wa=%b", $time, w, wa);
    @(cb);               // 5
    cb.w <= 1'b0;
    cb.wa <= 1'b0;
    #1 $display("t=%0d: w=%b wa=%b", $time, w, wa);
    @(cb);               // 15
    cb.w <= 1'bz;
    cb.wa <= 1'b1;
    #1 $display("t=%0d: w=%b wa=%b", $time, w, wa);
    $finish;
  end
endmodule
