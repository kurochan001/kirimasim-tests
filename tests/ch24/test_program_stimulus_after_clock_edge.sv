/*
:name: test_program_stimulus_after_clock_edge
:description: A program that waits for a clock edge resumes after the design has processed the edge, so the value it then writes is captured by the design only at the next edge (IEEE 1800-2023 Section 24.4)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.4 24.3.1 4.4.2.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_stimulus_after_clock_edge.expected
*/
// IEEE 1800-2023 §24.4: a program runs in the Reactive region, after all the
// events of the design in the time step, including a clock driven by a
// nonblocking assignment. §24.3.1: the program resumes from @(posedge clk) in
// the Reactive region. So at each rising edge the register of the design
// takes d before the program writes the next value of d, and q follows d one
// clock later with no race; the program prints q after the update of the
// edge. The program ends the run with $finish, as the clock never stops.
// Icarus Verilog 13.0 and Verilator 5.052 resume the program before the update
// of q and print the value of the edge before (docs/simulator-differences.md).

module test_program_stimulus_after_clock_edge_dut(input logic clk, input int d, output int q);
  always @(posedge clk) q <= d;
endmodule

program test_program_stimulus_after_clock_edge_tb(input logic clk, input int q, output int d);
  initial begin
    d = 1;
    repeat (4) begin
      @(posedge clk);
      $display("edge: q=%0d", q);
      d = d + 1;
    end
    $finish;
  end
endprogram

module test_program_stimulus_after_clock_edge;
  logic clk = 0;
  int d, q;
  always #5 clk <= ~clk;
  test_program_stimulus_after_clock_edge_dut dut(clk, d, q);
  test_program_stimulus_after_clock_edge_tb tb(clk, q, d);
endmodule
