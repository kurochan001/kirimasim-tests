/*
:name: test_gate_min_typ_max_delay
:description: A gate with min:typ:max delays changes its output after one of the three delays, whichever the tool selects, so only times outside all three are checked (IEEE 1800-2023 Section 28.16.1)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.16.1 28.16
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_gate_min_typ_max_delay.expected
*/
// IEEE 1800-2023 §28.16.1: a gate delay can be written as min:typ:max for its
// rise and fall; which of the three a run uses is up to the tool. The buf has
// a rise of 2:3:4 and a fall of 5:6:7, so after the input rises at 10 the
// output is still 0 at 11 and is 1 at 15; after it falls at 20 the output is
// still 1 at 24 and 0 at 28, whichever delay is used. The times are chosen
// apart from the times of the changes, so that no check falls into the time
// step in which the output changes.

`timescale 1ns/1ns

module test_gate_min_typ_max_delay;
  logic a = 1'b0;
  wire y;

  buf #(2:3:4, 5:6:7) b(y, a);

  initial begin
    #10 a = 1'b1;
    #1 $display("t=%0d y=%b", $time, y);
    #4 $display("t=%0d y=%b", $time, y);
    #5 a = 1'b0;
    #4 $display("t=%0d y=%b", $time, y);
    #4 $display("t=%0d y=%b", $time, y);
  end
endmodule
