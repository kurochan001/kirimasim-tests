/*
:name: test_nba_then_event_control_same_step
:description: A process that makes a nonblocking assignment to a variable and then waits for it resumes in the same time step, also through a virtual interface (IEEE 1800-2023 Section 10.4.2)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2 4.4.2.4 9.4.2 25.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nba_then_event_control_same_step.expected
*/
// IEEE 1800-2023 §10.4.2: "v <= ~v" schedules the update of v for the NBA
// region (4.4.2.4) of the current time step, and the process goes on. When
// it then waits with @(v) (9.4.2), the update of the same time step wakes
// it, so it continues in that time step, not one later. This holds for a
// variable of an interface written through a virtual interface (25.9) as for
// one written directly.

interface toggle_if (input logic clk);
  bit nb = 0;
endinterface

class toggler;
  virtual toggle_if vif;
  task run();
    @(posedge vif.clk);
    $display("A t=%0d", $time);
    vif.nb <= ~vif.nb;
    @(vif.nb);
    $display("B t=%0d", $time);
    #1;
    vif.nb <= ~vif.nb;
    @(vif.nb);
    $display("C t=%0d", $time);
  endtask
endclass

module test_nba_then_event_control_same_step;
  logic clk = 0;
  always #5 clk = ~clk;
  toggle_if i (clk);
  toggler t;

  initial begin
    t = new;
    t.vif = i;
    t.run();
    @(posedge clk);
    $display("D t=%0d", $time);
    i.nb <= ~i.nb;
    @(i.nb);
    $display("E t=%0d", $time);
    $finish;
  end
endmodule
