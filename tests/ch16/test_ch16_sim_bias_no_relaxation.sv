/*
:name: test_ch16_sim_bias_no_relaxation
:description: an assumed property with a dist condition is checked as an inside condition and fails for a value outside the set, exactly as the same property without dist, so biasing does not relax the assumption (IEEE 1800-2023 Section 16.14.2)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.2 18.5.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout_verilator: @test_ch16_sim_bias_no_relaxation.expected
*/
// IEEE 1800-2023 §16.14.2: when a property with biasing is used within an
// assert or cover statement, the dist operator is equivalent to the inside
// operator and the weight specification is ignored; the properties that are
// assumed shall hold in the same way with or without biasing, the weights
// only selecting values of free variables when there is a choice. ad and ai
// assume the same set, {0, 1}, one written with dist and one with inside.
// v is 0, 1, 2 and 3 at the clock ticks at 5, 15, 25 and 35, so both assumed
// properties fail at 25 and at 35 and at no other tick. The two failure
// queues are printed separately, so the order of two action blocks in one
// time step does not matter, and equal queues show that the weights neither
// widen the set nor make the assumption pass for a value outside it.
// Icarus Verilog 13.0 has no concurrent assertions, so it has no expected
// output of its own.

`timescale 1ns/1ns

module test_ch16_sim_bias_no_relaxation;
  logic clk = 0;
  int v = 0;
  int dist_fail[$], inside_fail[$];

  always #5 clk = ~clk;

  ad: assume property (@(posedge clk) v dist {0 := 40, 1 := 60})
    else dist_fail.push_back($time);

  ai: assume property (@(posedge clk) v inside {0, 1})
    else inside_fail.push_back($time);

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0t", q[i])};
    return s;
  endfunction

  initial begin
    v = 0;
    #10 v = 1;
    #10 v = 2;
    #10 v = 3;
    #10;
    $display("dist fails at:%s", times(dist_fail));
    $display("inside fails at:%s", times(inside_fail));
    $finish;
  end
endmodule
