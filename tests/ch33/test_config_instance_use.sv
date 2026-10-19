/*
:name: test_config_instance_use
:description: An instance clause with use binds one instance to another cell, while the other instances of the same module keep their own (IEEE 1800-2023 Section 33.4.1.3)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.4.1.3 33.4.1.6 33.4.1.2 33.4.1.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_config_instance_use.expected
*/
// IEEE 1800-2023 §33.4.1.3, §33.4.1.6: "instance <path> use <lib>.<cell>" binds
// that one instance to the named cell, which may have another name than the
// module the instance names. §33.4.1.2, §33.4.1.5: the default liblist work
// binds every other instance to the cell of its own name in work. Both
// instances name cfg_leaf_a; only u2 becomes a cfg_leaf_b. Icarus Verilog 13.0
// skips config declarations. Verilator 5.052 gives this output only when
// --top-module names this module.

module cfg_leaf_a(output logic [7:0] y);
  assign y = 8'haa;
endmodule

module cfg_leaf_b(output logic [7:0] y);
  assign y = 8'hbb;
endmodule

module test_config_instance_use;
  logic [7:0] y1, y2;

  cfg_leaf_a u1(y1);
  cfg_leaf_a u2(y2);

  initial #1 $display("u1=%h u2=%h", y1, y2);
endmodule

config cfg;
  design work.test_config_instance_use;
  default liblist work;
  instance test_config_instance_use.u2 use work.cfg_leaf_b;
endconfig
