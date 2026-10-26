/*
:name: test_instance_before_definition_connection_kinds
:description: A module can be instantiated more than once before its definition, and its connections can be a net, a variable, an interface, an event and an expression (IEEE 1800-2023 Section 23.3.2)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.2 23.3.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_instance_before_definition_connection_kinds.expected
*/
// IEEE 1800-2023 §23.3.2: the module name of an instantiation can be one
// declared later in the source, and hierarchical instantiation allows more
// than one instance of the same module. Port connections can be nets,
// variables, interfaces, events or expressions. The module fwd_child is
// declared after fwd_top, which has two instances of it: c1 receives the net
// net_in, the variable var_in, the interface itf, the event ev and the
// expression var_in + 1, and c2 receives the same net, variable, interface and
// event and the expression 15. Each instance adds its four 4-bit inputs,
// drives its output and counts the triggers of its event port, which the
// parent triggers once.

interface fwd_if;
  logic [3:0] d;
endinterface

// Icarus Verilog 13.0 has no event or interface ports, so the expected output
// is recorded with Verilator 5.052 alone.

module fwd_top;
  wire [3:0] net_in = 4'h3;
  logic [3:0] var_in = 4'h5;
  fwd_if itf();
  event ev;
  wire [5:0] o1, o2;
  int h1, h2;

  fwd_child c1(.n(net_in), .v(var_in), .p(itf), .e(ev), .x(var_in + 4'h1),
               .o(o1), .hits(h1));
  fwd_child c2(.n(net_in), .v(var_in), .p(itf), .e(ev), .x(4'hf),
               .o(o2), .hits(h2));

  initial begin
    itf.d = 4'h9;
    #1 -> ev;
    #1 $display("event released");
    $display("o1=%0d o2=%0d hits=%0d,%0d", o1, o2, h1, h2);
  end
endmodule

module fwd_child(input [3:0] n, input [3:0] v, fwd_if p, input [3:0] x,
                 input var event e, output [5:0] o, output int hits);
  assign o = {2'b0, n} + {2'b0, v} + {2'b0, p.d} + {2'b0, x};

  always @(e) hits++;
endmodule
