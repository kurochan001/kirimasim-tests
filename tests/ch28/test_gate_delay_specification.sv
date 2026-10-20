/*
:name: test_gate_delay_specification
:description: A gate without a delay specification changes its output at once; one, two or three delays give the rise, fall and turn-off delays (IEEE 1800-2023 Section 28.3.3)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.3.3 28.16 28.16.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_gate_delay_specification.expected
*/
// IEEE 1800-2023 §28.3.3: gates and switches declared without a delay
// specification have no propagation delay, and a delay specification has up
// to three values (28.16). The buf without delay follows a at once; the one
// with #(2, 4) rises 2 and falls 4 after a; the bufif1 with #(1, 3, 5) turns
// off 5 after its enable falls. Apart from the first, which a #0 orders after
// the update, the values are printed one time unit before and after each
// change, never at the time of the change.

`timescale 1ns/1ns

module test_gate_delay_specification;
  logic a = 0, en = 1;
  wire now_out, rf_out, tri_out;

  buf (now_out, a);
  buf #(2, 4) (rf_out, a);
  bufif1 #(1, 3, 5) (tri_out, a, en);

  initial begin
    #10 a = 1;
    #0 $display("t=%0t: no delay %b", $time, now_out);
    #1 $display("t=%0t: rise pending %b", $time, rf_out);
    #2 $display("t=%0t: rise %b", $time, rf_out);
    #7 a = 0;
    #3 $display("t=%0t: fall pending %b", $time, rf_out);
    #2 $display("t=%0t: fall %b", $time, rf_out);
    #5 en = 0;
    #4 $display("t=%0t: off pending %b", $time, tri_out);
    #2 $display("t=%0t: off %b", $time, tri_out);
  end
endmodule
