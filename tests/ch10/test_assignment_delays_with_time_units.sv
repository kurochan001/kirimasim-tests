/*
:name: test_assignment_delays_with_time_units
:description: delays written with a time unit in a statement delay, an intra-assignment delay of a blocking and of a nonblocking assignment, and a continuous assignment delay are scaled to the time unit of the module (IEEE 1800-2023 Section 10.2)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.2 5.8 9.4.5 10.3.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assignment_delays_with_time_units.expected
*/
// IEEE 1800-2023 §10.2: the delay of an assignment may be written with a time
// unit, as a time literal. By 5.8 a time literal is scaled to the time unit
// of the module and rounded to its precision.
//
// The time unit is 1 ns and the precision 1 ps. The delays are written in ps
// and us: #1500ps before a blocking assignment (1.5 ns), = #0.002us inside a
// blocking assignment (2 ns), <= #250ps inside a nonblocking assignment
// (0.25 ns) and #750ps on a continuous assignment (0.75 ns). The procedure
// prints $realtime, in ns, when each assignment is made, and another
// procedure samples the continuously assigned w just before and just after
// it has to change. A tool that took the numbers as ns would print other times.

`timescale 1ns/1ps

module test_assignment_delays_with_time_units;
  logic a = 1'b0, r_intra = 1'b0, r_nb = 1'b0;
  wire w;

  assign #750ps w = a;

  initial begin
    #1500ps a = 1'b1;
    $display("a=%b at %0.3f", a, $realtime);
    r_intra = #0.002us a;
    $display("r_intra=%b at %0.3f", r_intra, $realtime);
    r_nb <= #250ps a;
    #200ps $display("r_nb=%b at %0.3f", r_nb, $realtime);
    #100ps $display("r_nb=%b at %0.3f", r_nb, $realtime);
  end

  initial begin
    #2200ps $display("w=%b at %0.3f", w, $realtime);
    #100ps $display("w=%b at %0.3f", w, $realtime);
  end
endmodule
