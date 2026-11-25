/*
:name: test_vcd_comment_insertion_preserves_dumpall
:description: A size-limited VCD supplies a dumper comment and a checkpoint for testing inserted sections
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.2.3 21.7.2.1 21.7.1.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: VCD keyword fixture finished
*/

`timescale 1ns/10ps
module test_vcd_comment_insertion_preserves_dumpall;
  reg [15:0] value = 16'h0123;

  initial begin
    $dumpfile("sections.vcd");
    $dumpvars(0, test_vcd_comment_insertion_preserves_dumpall);
    #1 value = 16'h4567;
    #1 $dumpall;
    #1 $dumplimit(800);
    repeat (100) #1 value = value + 1;
    #1 $display("VCD keyword fixture finished");
  end
endmodule
