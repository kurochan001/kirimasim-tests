/*
:name: test_udp_instance_delay_name_and_terminal_forms
:description: UDP instances take an optional delay of one or two values and an optional name, several of them can share one statement, and their output-first terminals can be expressions or constants (IEEE 1800-2023 Section 29.8)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.8 29.3.2 28.3.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_udp_instance_delay_name_and_terminal_forms.expected
*/
// IEEE 1800-2023 §29.8: a UDP instance is written like a gate instance: the
// UDP name, an optional drive strength, an optional delay of one or two
// values, and one or more instances, each with an optional name, which may
// have a range for an array of instances, and its terminals, the output
// first and then the inputs in the order of the UDP header. §29.3.2: the
// rules for primitive terminals apply to UDP terminals, so an input can be
// an expression or a constant (28.3.6). u_buf is a buffer and u_and2 an and
// of two inputs. One instance has no name, g_d has the delay 3 for every
// change, g_rf the rise delay 2 and the fall delay 4, g_m1 and g_m2 are
// declared in one statement, and g_d and g_c have an expression or a
// constant as an input. The inputs change at 10, 20 and 30, and the outputs
// are printed at times between the changes.

`timescale 1ns/1ns
primitive u_buf(y, a);
  output y;
  input a;
  table
    0 : 0;
    1 : 1;
  endtable
endprimitive

primitive u_and2(y, a, b);
  output y;
  input a, b;
  table
    1 1 : 1;
    0 ? : 0;
    ? 0 : 0;
  endtable
endprimitive

module test_udp_instance_delay_name_and_terminal_forms;
  logic a, b;
  wire o_n, o_d, o_rf, o_m1, o_m2, o_c;

  u_buf (o_n, a);
  u_and2 #3 g_d(o_d, a, ~b);
  u_buf #(2, 4) g_rf(o_rf, a);
  u_buf g_m1(o_m1, a), g_m2(o_m2, b);
  u_and2 g_c(o_c, a | b, 1'b1);

  task show;
    $display("t=%0d: unnamed=%b d=%b rf=%b m1=%b m2=%b c=%b", $time,
             o_n, o_d, o_rf, o_m1, o_m2, o_c);
  endtask

  initial begin
    a = 1'b0; b = 1'b0;
    #9 show;
    #1 a = 1'b1;
    #1 show;
    #3 show;
    #6 b = 1'b1;
    #2 show;
    #2 show;
    #6 a = 1'b0;
    #2 show;
    #3 show;
  end
endmodule
