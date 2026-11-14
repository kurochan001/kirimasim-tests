/*
:name: test_net_driven_by_assign_gate_and_module_output
:description: one net is driven at once by a continuous assignment, a gate output and a module output, and its value resolves all three drivers by the rules of its net type, for a wire and for a wor (IEEE 1800-2023 Section 10.3.2)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_net_driven_by_assign_gate_and_module_output.expected
*/
// IEEE 1800-2023 §10.3.2: a net can be driven by several continuous
// assignments or by a mixture of primitive outputs, module outputs and
// continuous assignments, and its value is then the resolution of all its
// drivers by the rules of its net type (§6.6.1 for wire, §6.6.3 for wor).
//
// The wire w has three drivers, each of which drives z unless it is enabled:
// a continuous assignment (en_a, d_a), the bufif1 gate g1 (en_g, d_g) and the
// output port y of u1, an instance of tri_drv (en_m, d_m). All three drive
// with strong strength. With none enabled w is z; with one enabled w has its
// value, whichever of the three it is; two enabled drivers of the same value
// give that value, and two of opposite values give x.
// The wor o has three drivers that are always on: a continuous assignment of
// x_a, the buf gate g2 of x_g and the output port y of u2, an instance of
// copy_drv that drives x_m; that port is a wor too, so the port connection
// joins nets of one net type. The value of o is the OR of the three, so it
// is 1 when any one of them is 1.
// Each value is printed one time unit after the inputs change.

module tri_drv(input logic en, input logic d, output wire y);
  assign y = en ? d : 1'bz;
endmodule

module copy_drv(input logic d, output wor y);
  assign y = d;
endmodule

module test_net_driven_by_assign_gate_and_module_output;
  logic en_a, d_a, en_g, d_g, en_m, d_m;
  logic x_a, x_g, x_m;
  wire w;
  wor o;

  assign w = en_a ? d_a : 1'bz;
  bufif1 g1 (w, d_g, en_g);
  tri_drv u1 (.en(en_m), .d(d_m), .y(w));

  assign o = x_a;
  buf g2 (o, x_g);
  copy_drv u2 (.d(x_m), .y(o));

  initial begin
    en_a = 0; d_a = 0; en_g = 0; d_g = 0; en_m = 0; d_m = 0;
    x_a = 0; x_g = 0; x_m = 0;
    #1 $display("none enabled: w=%b", w);
    en_a = 1; d_a = 1;
    #1 $display("assignment 1: w=%b", w);
    en_a = 0; en_g = 1; d_g = 0;
    #1 $display("gate 0: w=%b", w);
    en_g = 0; en_m = 1; d_m = 1;
    #1 $display("module 1: w=%b", w);
    d_m = 0;
    #1 $display("module 0: w=%b", w);
    en_g = 1; d_g = 0;
    #1 $display("gate 0, module 0: w=%b", w);
    en_g = 0; en_a = 1; d_a = 1;
    #1 $display("assignment 1, module 0: w=%b", w);
    en_m = 0; en_g = 1; d_g = 0;
    #1 $display("assignment 1, gate 0: w=%b", w);
    #1 $display("wor all 0: o=%b", o);
    x_a = 1;
    #1 $display("wor assignment 1: o=%b", o);
    x_a = 0; x_g = 1;
    #1 $display("wor gate 1: o=%b", o);
    x_g = 0; x_m = 1;
    #1 $display("wor module 1: o=%b", o);
    x_a = 1; x_g = 1;
    #1 $display("wor all 1: o=%b", o);
  end
endmodule
