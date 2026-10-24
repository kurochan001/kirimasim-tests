/*
:name: test_gate_delay_table_all_transitions
:description: bufif1 gates with no delay, one, two and three delays change their output after the delay that Table 28-9 gives for each of the 12 transitions between 0, 1, x and z (IEEE 1800-2023 Section 28.16)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.16 28.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_gate_delay_table_all_transitions.expected
*/
// IEEE 1800-2023 §28.16, Table 28-9 (and §28.6 for the three-state gates):
// a gate with no delay changes its output at once and one with one delay
// uses it for every transition. With two delays d1 is used for a change to
// 1, d2 for a change to 0, and the smaller of the two for a change to x or
// z. With three delays d1 is used for a change to 1, d2 for a change to 0,
// d3 for a change to z and the smallest of the three for a change to x.
// Seven bufif1 gates share their data and control inputs, which take the
// output through all 12 transitions between 0, 1, x and z, 20 time units
// apart; some transitions come from the data input and some from the
// control input, as the delay counts from any input. The delays are chosen
// so that each rule gives a value that the other choices do not give
// everywhere: (3,5) and (5,3) for two delays and (2,4,6), (6,2,4) and
// (4,6,2) for three, where each delay is once the smallest. For every gate
// an always procedure records the time of the last change of its output,
// and 19 time units after each input change the delay since that change
// and the output value are printed.

`timescale 1ns/1ns
module test_gate_delay_table_all_transitions;
  logic [1:0] dc;  // {data, control}
  wire o_0, o_4, o_35, o_53, o_246, o_624, o_462;

  bufif1 g_0(o_0, dc[1], dc[0]);
  bufif1 #4 g_4(o_4, dc[1], dc[0]);
  bufif1 #(3, 5) g_35(o_35, dc[1], dc[0]);
  bufif1 #(5, 3) g_53(o_53, dc[1], dc[0]);
  bufif1 #(2, 4, 6) g_246(o_246, dc[1], dc[0]);
  bufif1 #(6, 2, 4) g_624(o_624, dc[1], dc[0]);
  bufif1 #(4, 6, 2) g_462(o_462, dc[1], dc[0]);

  time t_0, t_4, t_35, t_53, t_246, t_624, t_462;
  always @(o_0) t_0 = $time;
  always @(o_4) t_4 = $time;
  always @(o_35) t_35 = $time;
  always @(o_53) t_53 = $time;
  always @(o_246) t_246 = $time;
  always @(o_624) t_624 = $time;
  always @(o_462) t_462 = $time;

  // Applies the next input pair and prints, after 19 time units, how long
  // after the input change each output last changed, and its value.
  task automatic step(string what, logic [1:0] v);
    time t;
    dc = v;
    t = $time;
    #19;
    $write("%s: none=+%0d %b one=+%0d %b (3,5)=+%0d %b (5,3)=+%0d %b",
           what, t_0 - t, o_0, t_4 - t, o_4, t_35 - t, o_35, t_53 - t, o_53);
    $display(" (2,4,6)=+%0d %b (6,2,4)=+%0d %b (4,6,2)=+%0d %b",
             t_246 - t, o_246, t_624 - t, o_624, t_462 - t, o_462);
    #1;
  endtask

  initial begin
    dc = 2'b01;  // output 0
    #20;
    step("0->1", 2'b11);
    step("1->0", 2'b01);
    step("0->x", 2'bx1);
    step("x->0", 2'b01);
    step("0->z", 2'b00);
    step("z->1", 2'b11);
    step("1->x", 2'bx1);
    step("x->1", 2'b11);
    step("1->z", 2'b10);
    step("z->x", 2'bx1);
    step("x->z", 2'bx0);
    step("z->0", 2'b01);
  end
endmodule
