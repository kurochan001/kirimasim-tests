/*
:name: test_checker_procedural_instance
:description: The assertions of a checker instantiated in procedural code are checked only at the clock ticks where the instance is reached, while its always_ff procedure, like that of a static instance, runs at every tick (IEEE 1800-2023 Section 17.3)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.3 16.14.6 17.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_procedural_instance.expected
*/
// IEEE 1800-2023 §17.3: c_out is a static checker instance, and its assertion
// is checked at every rising clock. c_in, inside an always procedure, is a
// procedural instance: its static assertion is queued like a procedural
// concurrent assertion (16.14.6) only when the if reaches it, so w = 5 at 35,
// with en = 0, is not reported. All other contents of a checker instance
// exist at every time step, so the always_ff procedures of both instances
// count all five ticks (17.5). v and w change at the falling clock.

checker chk (event clk, logic [3:0] v, int id, output int ticks = 0);
  always_ff @clk ticks <= ticks + 1;
  a1: assert property (@clk v != 4'd5)
    else $display("t=%0d: checker %0d sees 5", $time, id);
endchecker

module test_checker_procedural_instance;
  logic clk = 0, en = 0;
  logic [3:0] v = 0, w = 0;
  int t_out, t_in;

  always #5 clk = ~clk;

  chk c_out (posedge clk, v, 1, t_out);

  always @(posedge clk)
    if (en) chk c_in (posedge clk, w, 2, t_in);

  initial begin
    #10 v = 5;        // c_out reports at 15
    #10 v = 0;
    w = 5;
    en = 1;           // c_in reports at 25
    #10 en = 0;       // w is still 5 at 35, but c_in is not reached
    #10 v = 5;        // c_out reports at 45
    #10 $display("ticks: c_out %0d, c_in %0d", t_out, t_in);
    $finish;
  end
endmodule
