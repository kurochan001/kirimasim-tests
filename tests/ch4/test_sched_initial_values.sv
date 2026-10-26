/*
:name: test_sched_initial_values
:description: variables and nets have their default or declared initial values before the first time-slot event processing, and initialization events are in the time-zero slot (IEEE 1800-2023 4.5)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sched_initial_values.expected
*/
// IEEE 1800-2023 §4.5: the initial value of a variable or net is established
// under its type's rules before the events of the first time slot are
// processed, and the initialization events themselves are scheduled in the
// time-zero slot. The test reads every kind without assigning it: int is 0,
// bit is 0, logic is x, wire is z, real is 0.0 and string is empty, while the
// declared initializers 4'hA and 5 are already visible. A delay of #0 stays
// in the time-zero slot. A simulator that starts processes before
// initialization, or that puts the first slot at another time, prints a
// different line. Verilator 5.052 is a two-state simulator and prints 0 for
// the x and z values, so the expected output lists Icarus Verilog 13.0 only.

module test_sched_initial_values;
  int i;
  logic [3:0] l;
  bit [3:0] b;
  logic [3:0] li = 4'hA;
  int j = 5;
  wire w;
  real r;
  string s;

  initial begin
    $display("i=%0d b=%0d li=%h j=%0d", i, b, li, j);
    $display("l=%b w=%b", l, w);
    $display("r=%0.1f empty=%0d t=%0d", r, s == "", $time);
    #0 $display("zero t=%0d i=%0d", $time, i);
    $finish;
  end
endmodule
