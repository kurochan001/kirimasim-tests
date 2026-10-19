/*
:name: test_checker_concurrent_assertion
:description: A concurrent assertion inside a checker, clocked by the default clocking of the checker, runs its action blocks for each instance (IEEE 1800-2023 Section 17.2)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.2 17.3 16.14 14.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_concurrent_assertion.expected
*/
// IEEE 1800-2023 §17.2: a checker body may hold a default clocking and
// concurrent assertions (16.14), whose action blocks are checker action blocks.
// §17.3: each instance checks its own actual arguments. Here every request must
// be followed by an acknowledge at the next clock edge (req |=> ack); each
// instance prints its number and the time of each failure from its else action.

`timescale 1ns/1ns

checker req_then_ack(logic req, logic ack, event clk, int id);
  default clocking @clk; endclocking
  a_handshake: assert property (req |=> ack)
    else $display("%0d: c%0d: ack missing", $time, id);
endchecker

module test_checker_concurrent_assertion;
  logic clk = 0;
  logic req1 = 0, ack1 = 0;
  logic req2 = 0, ack2 = 0;

  always #5 clk = ~clk;   // posedges at 5, 15, 25, 35, 45

  req_then_ack c1(req1, ack1, posedge clk, 1);
  req_then_ack c2(req2, ack2, posedge clk, 2);

  initial begin
    #1;
    req1 = 1;            // sampled at 5
    req2 = 1;
    #10;                 // 11
    req1 = 0;
    ack1 = 1;            // sampled at 15: c1 passes
    req2 = 0;            // ack2 stays 0: c2 fails at 15
    #10;                 // 21
    ack1 = 0;
    req1 = 1;            // sampled at 25
    #10;                 // 31: ack1 stays 0: c1 fails at 35
    req1 = 0;
    #20 $finish;
  end
endmodule
