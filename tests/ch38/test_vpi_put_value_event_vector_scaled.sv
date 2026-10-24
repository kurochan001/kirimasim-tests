/*
:name: test_vpi_put_value_event_vector_scaled
:description: vpi_put_value triggers a named event with or without a value, sets each bit from an aval/bval pair coded 00, 10, 11 and 01 for 0, 1, x and z, and takes a vpiScaledRealTime delay in the time unit of the object it writes (IEEE 1800-2023 Section 38.34)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.34 38.15 38.36.2 38.36.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:vpi_c: @test_vpi_put_value_event_vector_scaled.c
:expected_stdout: @test_vpi_put_value_event_vector_scaled.expected
*/
// IEEE 1800-2023 §38.34: vpi_put_value on a vpiNamedEvent triggers the event;
// it needs no value, and value_p can be NULL. With vpiVectorVal, the value is
// an array of s_vpi_vecval, element 0 holding bits 0 to 31 and element 1 bits
// 32 to 63, each bit coded by (aval bit, bval bit): 0 as (0,0), 1 as (1,0), x
// as (1,1) and z as (0,1) (38.15). A delay of type vpiScaledRealTime is in the
// time unit of the object written. In a cbAfterDelay callback at 5 (38.36.2),
// registered at the start of the simulation (38.36.3), the application
// triggers ev with value_p NULL; puts aval 66 and bval cc (hex) into the
// 8-bit pv; puts into the 40-bit w ffffffff and 0 as element 0 and 1 and 2 as
// element 1; and puts 1 into t_top and u_sub.s_sub with a vpiScaledRealTime
// delay of 3.0, the top module having a time unit of 1 ns and u_sub of 10 ns.
// A second callback, at 8, triggers ev with a value. The design prints at
// fixed times.

`timescale 10ns/1ns
module put_scaled_sub;
  int s_sub;
endmodule

`timescale 1ns/1ns
module test_vpi_put_value_event_vector_scaled;
  event ev;
  logic [7:0] pv;
  logic [39:0] w;
  int t_top;

  put_scaled_sub u_sub();

  always @(ev) $display("%0t: ev triggered", $time);

  initial begin
    #6 $display("6: pv=%b w[39:32]=%b w[31:0]=%h", pv, w[39:32], w[31:0]);
    #1 $display("7: t_top=%0d s_sub=%0d", t_top, u_sub.s_sub);
    #2 $display("9: t_top=%0d s_sub=%0d", t_top, u_sub.s_sub);
    #25 $display("34: t_top=%0d s_sub=%0d", t_top, u_sub.s_sub);
    #2 $display("36: t_top=%0d s_sub=%0d", t_top, u_sub.s_sub);
  end
endmodule
