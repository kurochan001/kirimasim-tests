/*
:name: test_static_initializer_runs_once
:description: The initializer of a static variable declared in a procedural block runs once before time 0, not on each entry to the block (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.21 6.8
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_static_initializer_runs_once.expected
*/
// IEEE 1800-2023 §6.21: a variable declared static in a block of a procedure
// or of a task exists for the whole simulation, and its initializer is
// evaluated once, before any procedure starts (6.8), not each time the
// block is entered. A counter declared "static int c = 0" in an always
// procedure therefore counts every activation, one declared in a task
// counts every call, and "static int stamp = $time" in a block entered at
// time 5 holds 0.

module test_static_initializer_runs_once;
  logic clk = 0;

  always @(posedge clk) begin
    static int c = 0;
    c++;
    $display("t=%0d always: c=%0d", $time, c);
  end

  task count_calls;
    static int calls = 0;
    calls++;
    $display("count_calls: calls=%0d", calls);
  endtask

  initial begin
    #5;
    begin
      static int stamp = $time;
      $display("t=%0d stamp=%0d", $time, stamp);
    end
    count_calls;
    count_calls;
    repeat (6) #5 clk = ~clk;
  end
endmodule
