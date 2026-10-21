/*
:name: test_assertions_in_interface_and_program
:description: concurrent assertions written outside procedural code in an interface, one per interface instance with its own signals, and in a program start an evaluation attempt at every tick of their clocks, while a restrict property in the interface is not checked (IEEE 1800-2023 Section 16.14.5)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.5 16.14.4 16.14.1 25.3 24.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assertions_in_interface_and_program.expected
*/
// IEEE 1800-2023 §16.14.5: a concurrent assertion statement can be written
// outside procedural code in a module, an interface (§25.3) or a program
// (§24.3); it begins an evaluation attempt at every tick of its leading
// clock. Each instance of hs_if has its own a_hs on its own req and ack:
// both raise req at 15, i1 answers with ack at 25 and i2 does not, so only
// i2 fails, at 25. §16.14.4: restrict property is not checked in simulation
// and has no action block, so r_hs, violated by req at 15, has no effect.
// a_prog in the program counts its attempts through the module's variable
// n_prog: one at each of the five ticks, 5 to 45. The fail actions
// (§16.14.1) count. The program has no initial procedure, so it does not
// end the simulation.

`timescale 1ns/1ns

interface hs_if(input logic clk);
  logic req = 0, ack = 0;
  int fails = 0;
  a_hs: assert property (@(posedge clk) req |=> ack) else fails++;
  r_hs: restrict property (@(posedge clk) !req);
endinterface

program hs_prog(input logic clk);
  a_prog: assert property (@(posedge clk) 1'b1)
    test_assertions_in_interface_and_program.n_prog++;
endprogram

module test_assertions_in_interface_and_program;
  logic clk = 0;
  int n_prog = 0;

  hs_if i1(clk);
  hs_if i2(clk);
  hs_prog p(clk);

  initial begin
    repeat (10) #5 clk = ~clk;   // ticks at 5, 15, 25, 35 and 45
  end

  initial begin
    #10 i1.req = 1;
    i2.req = 1;
    #10 i1.req = 0;
    i2.req = 0;
    i1.ack = 1;
    #10 i1.ack = 0;
    #20;
    $display("i1 failures: %0d, i2 failures: %0d, program attempts: %0d", i1.fails, i2.fails,
             n_prog);
    $finish;
  end
endmodule
