/*
:name: test_clocking_sampled_event
:description: an event control on a clocking block input or inout uses the value sampled by the clocking event, not the unsampled signal
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_sampled_event.expected
*/
// IEEE 1800-2023 9.4.2: if an event expression denotes a clocking block input
// or inout, the event control uses the synchronous values sampled by the
// clocking event. x rises at 5 and y at 15, while the clock rises at 10 and
// 30. A wait on cb.x therefore wakes at 10, when the sampled x first differs
// from its previous sample, and not at 5; a wait on cb.y then wakes at 30.
// Both print the sampled value 1 even though the signal itself rose earlier.
// A tool that watches the unsampled signals wakes at 5 and 15.

`timescale 1ns/1ns

module test_clocking_sampled_event;
  logic clk = 0, x = 0, y = 0;

  clocking cb @(posedge clk);
    input x;
    inout y;
  endclocking

  initial begin
    @(cb.x);
    $display("x wake t=%0d x=%b cbx=%b", $time, x, cb.x);
    @(cb.y);
    $display("y wake t=%0d y=%b cby=%b", $time, y, cb.y);
  end

  initial begin
    #5 x = 1;
    #5 clk = 1;
    #5 y = 1;
    #5 clk = 0;
    #10 clk = 1;
    #10 $finish;
  end
endmodule
