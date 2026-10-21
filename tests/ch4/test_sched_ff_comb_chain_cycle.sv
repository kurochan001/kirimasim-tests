/*
:name: test_sched_ff_comb_chain_cycle
:description: A value goes through an always_ff, an always_comb and a second always_ff in two clock edges, since nonblocking updates are made after the edge (IEEE 1800-2023 Section 4.4.2.4)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.4 9.2.2.4 9.2.2.2 10.4.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_ff_comb_chain_cycle.expected
*/
// IEEE 1800-2023 §9.2.2.4: always_ff runs at each rising edge, and its
// nonblocking update (§10.4.2) comes in the NBA region (§4.4.2.4), after both
// flops have read their inputs. always_comb (§9.2.2.2) follows q at once, so y
// is q + 1 in the same time step, and z takes it at the next edge: d reaches q
// one edge after it changes and z two edges after. The test prints the values
// between edges.

`timescale 1ns/1ns

module test_sched_ff_comb_chain_cycle;
  bit clk = 0;
  int d = 0, q = 0, y, z = 0;

  always #5 clk = ~clk;
  always_ff @(posedge clk) q <= d;
  always_comb y = q + 1;
  always_ff @(posedge clk) z <= y;

  initial begin
    #2 d = 10;
    repeat (3) begin
      #10 $display("%0t: d=%0d q=%0d y=%0d z=%0d", $time, d, q, y, z);
      d = d + 10;
    end
    $finish;
  end
endmodule
