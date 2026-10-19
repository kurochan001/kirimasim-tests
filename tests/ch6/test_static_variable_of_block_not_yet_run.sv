/*
:name: test_static_variable_of_block_not_yet_run
:description: A static variable of a named block exists before the block first runs and can be written through its hierarchical name (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.21 23.6 9.3.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_static_variable_of_block_not_yet_run.expected
*/
// IEEE 1800-2023 §6.21: a variable declared in a block of a static procedure
// is static. It exists for the whole simulation, not only while the block
// runs, so it can be written and read through its hierarchical name (23.6,
// 9.3.4) before the block has run for the first time; the value written is
// kept until the block itself assigns the variable.

module holder (input logic clk);
  always @(posedge clk) begin : keep
    logic held;
    held = 1'b1;
  end
endmodule

module test_static_variable_of_block_not_yet_run;
  logic clk = 0;
  holder h (clk);

  initial begin
    #1 h.keep.held = 1'b0;
    #1 $display("before the block runs: h.keep.held = %b", h.keep.held);
    clk = 1;
    #1 $display("after the block runs: h.keep.held = %b", h.keep.held);
  end
endmodule
