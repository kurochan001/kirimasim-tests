/*
:name: test_udp_initial_value_not_delayed
:description: The initial value of a sequential UDP is on its output from the start of the simulation, also for an instance with a delay, while the changes after it are delayed (IEEE 1800-2023 Section 29.7)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.7 29.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_udp_initial_value_not_delayed.expected
*/
// IEEE 1800-2023 §29.7: the initial statement of a sequential UDP gives its
// output a value at the start of the simulation, and the delay of an instance
// (29.8) does not delay that assignment. So u_late, with delay 4, shows 1 at
// 1 like u_now. The rising clock at 1 loads d = 0: u_now changes at once,
// u_late 4 time units later, at 5.

primitive udp_dff1 (q, clk, d);
  output q;
  reg q;
  input clk, d;
  initial q = 1'b1;
  table
  // clk d : q : q+
     r   0 : ? : 0;
     r   1 : ? : 1;
     n   ? : ? : -;
     ?   * : ? : -;
  endtable
endprimitive

module test_udp_initial_value_not_delayed;
  reg clk, d;
  wire q_now, q_late;

  udp_dff1 u_now (q_now, clk, d);
  udp_dff1 #4 u_late (q_late, clk, d);

  initial begin
    clk = 0;
    d = 0;
    #1 $display("t=%0d: q_now=%b q_late=%b", $time, q_now, q_late);
    clk = 1;
    #1 $display("t=%0d: q_now=%b q_late=%b", $time, q_now, q_late);
    #2 $display("t=%0d: q_now=%b q_late=%b", $time, q_now, q_late);
    #2 $display("t=%0d: q_now=%b q_late=%b", $time, q_now, q_late);
  end
endmodule
