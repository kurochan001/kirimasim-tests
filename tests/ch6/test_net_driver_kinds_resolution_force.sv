/*
:name: test_net_driver_kinds_resolution_force
:description: A continuous assignment, a gate output and a module port each drive a net, their values combine by the resolution of the net type, a force overrides all of them, and after release the net has the resolved value of its drivers again (IEEE 1800-2023 Section 6.5)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.5 10.6.2 6.6.1 6.6.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_net_driver_kinds_resolution_force.expected
*/
// IEEE 1800-2023 §6.5: a net can be written by continuous assignments, by
// primitive outputs and through module ports, and the value of a net with
// several drivers is given by the resolution function of its net type. A force
// overrides the value of a net; when released, the net returns to the resolved
// value (10.6.2), which counts changes of the drivers made during the force.
// The nets n (wire), na (wand) and no (wor) each have three drivers: a
// continuous assignment from a, a buf gate from b and the output port of an
// instance from c. When exactly one of a, b and c is 0, that driver decides
// the value: the wire gets x (6.6.1), the wand 0 and the wor 1 (6.6.3); with
// all three at 1 every net is 1. Then n is forced to 0 while a changes, and
// released.

module test_net_driver_kinds_resolution_force_port(input logic d, output wire o);
  assign o = d;
endmodule

module test_net_driver_kinds_resolution_force;
  logic a = 1'b1, b = 1'b1, c = 1'b1;
  wire n;
  wand na;
  wor no;

  assign n = a;
  assign na = a;
  assign no = a;
  buf g_n(n, b);
  buf g_na(na, b);
  buf g_no(no, b);
  test_net_driver_kinds_resolution_force_port p_n(.d(c), .o(n));
  test_net_driver_kinds_resolution_force_port p_na(.d(c), .o(na));
  test_net_driver_kinds_resolution_force_port p_no(.d(c), .o(no));

  task automatic show(string what);
    $display("%s: abc=%b%b%b wire=%b wand=%b wor=%b", what, a, b, c, n, na, no);
  endtask

  initial begin
    #1 show("all 1");
    a = 1'b0;
    #1 show("assign 0");
    a = 1'b1;
    b = 1'b0;
    #1 show("gate 0");
    b = 1'b1;
    c = 1'b0;
    #1 show("port 0");
    c = 1'b1;
    #1 show("all 1");
    force n = 1'b0;
    #1 show("forced");
    a = 1'b0;
    #1 show("forced, a=0");
    release n;
    #1 show("released");
  end
endmodule
