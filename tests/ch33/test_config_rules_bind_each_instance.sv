/*
:name: test_config_rules_bind_each_instance
:description: A configuration is a named design element whose rules choose the source description bound to each instance, so two instances of the same module name can be bound to different cells, which %l shows (IEEE 1800-2023 Section 33.2)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_config_rules_bind_each_instance
:expected_stdout: @test_config_rules_bind_each_instance.expected
*/
// IEEE 1800-2023 §33.2: a configuration is a set of rules that specifies the
// source description used for each instance of a design; selecting it is
// binding the instance. Both instances below name crb_adder. The
// configuration crb_cfg binds a1 by its default liblist, to the cell
// crb_adder in work, and a2 by an instance rule to crb_adder_gate. Each cell
// prints its library.cell binding with %l (21.2.1.5, 33.7) and its sum, which
// differs between the two cells, at a time of its own.
// Icarus Verilog 13.0 skips config declarations and does not implement %l;
// version 5.052 of Verilator prints this output when --top-module names the
// test module, which the :top_module: field does.

module crb_adder(input logic [3:0] x, input logic [3:0] y, output logic [4:0] s);
  assign s = x + y;
  initial #2 $display("%m: %l s=%0d", s);
endmodule

module crb_adder_gate(input logic [3:0] x, input logic [3:0] y, output logic [4:0] s);
  assign s = x + y + 5'd16;
  initial #3 $display("%m: %l s=%0d", s);
endmodule

module test_config_rules_bind_each_instance;
  logic [3:0] p = 4'd3, q = 4'd4;
  wire [4:0] s1, s2;
  crb_adder a1 (p, q, s1);
  crb_adder a2 (p, q, s2);
endmodule

config crb_cfg;
  design work.test_config_rules_bind_each_instance;
  default liblist work;
  instance test_config_rules_bind_each_instance.a2 use work.crb_adder_gate;
endconfig
