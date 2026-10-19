/*
:name: test_always_body_event_control
:description: An always procedure whose body starts with an event control counts every event (IEEE 1800-2023 Section 9.2.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2 9.4.2 15.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_body_event_control.expected
*/
// IEEE 1800-2023 §9.2.2: an always procedure starts at time 0 and runs its
// statement over and over. When that statement is a begin-end block whose first
// statement is an event control (9.4.2), the procedure waits there in every
// round, so it counts every posedge, every negedge and every trigger of a named
// event (15.5.1) after time 0.

module test_always_body_event_control;
  logic clk = 1'b0;
  event  ev;
  int a_cnt = 0;  // posedge
  int n_cnt = 0;  // negedge
  int e_cnt = 0;  // named event
  // posedges at 5, 15, 25, 35; negedges at 10, 20, 30
  always #5 clk = ~clk;
  always begin
    @(posedge clk);
    a_cnt = a_cnt + 1;
  end
  always begin
    @(negedge clk);
    n_cnt = n_cnt + 1;
  end
  always begin
    @(ev);
    e_cnt = e_cnt + 1;
  end
  initial begin
    #10;  -> ev;   // t=10
    #10;  -> ev;   // t=20
    #18;           // t=38
    if (a_cnt !== 4) $display("CHECK-FAIL a_cnt=%0d (want 4)", a_cnt);
    if (n_cnt !== 3) $display("CHECK-FAIL n_cnt=%0d (want 3)", n_cnt);
    if (e_cnt !== 2) $display("CHECK-FAIL e_cnt=%0d (want 2)", e_cnt);
    if (a_cnt === 4 && n_cnt === 3 && e_cnt === 2) $display("TEST PASSED");
    else $display("TEST FAILED");
    $finish;
  end
endmodule
