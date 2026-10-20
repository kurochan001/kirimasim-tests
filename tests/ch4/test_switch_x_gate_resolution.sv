/*
:name: test_switch_x_gate_resolution
:description: A node on the far side of a bidirectional switch whose gate is x takes a known value only when the switch being on and being off give it the same value (IEEE 1800-2023 Section 4.9.5)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.9.5 28.8 28.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_switch_x_gate_resolution.expected
*/
// IEEE 1800-2023 §4.9.5: when the gate of a tranif1 (28.8) is x, the network
// is solved with the switch on and with it off, and a node that has the same
// value both ways keeps it; otherwise it is x. Each far node has a pullup
// or a pulldown (28.12) and its near node a strong driver. With a strong 1
// near and a pullup far, the far node is 1 either way; with a strong 0 near
// and a pullup far it is 0 or 1, so x; a strong 0 near and a pulldown far
// give 0. When the gate is 1 the far node follows the near one, and when it
// is 0 it has its pull value.

module test_switch_x_gate_resolution;
  reg g;
  wire near1, far1, near2, far2, near3, far3;

  assign near1 = 1'b1;
  assign near2 = 1'b0;
  assign near3 = 1'b0;
  pullup (far1);
  pullup (far2);
  pulldown (far3);
  tranif1 t1 (near1, far1, g);
  tranif1 t2 (near2, far2, g);
  tranif1 t3 (near3, far3, g);

  task show;
    #1 $display("g=%b: far1=%b far2=%b far3=%b near2=%b", g, far1, far2, far3, near2);
  endtask

  initial begin
    g = 1'b1;
    show;
    g = 1'b0;
    show;
    g = 1'bx;
    show;
  end
endmodule
