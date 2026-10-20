/*
:name: test_config_instance_deep_path
:description: An instance clause names one instance by its hierarchical path from the top-level cell of the config, also several levels down, and other instances of the same module keep their binding (IEEE 1800-2023 Section 33.4.1.3)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.4.1.3 33.4.1.6 33.4.1.2 33.4.1.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_config_instance_deep_path.expected
*/
// IEEE 1800-2023 §33.4.1.3: the path of an instance clause is a hierarchical
// name that starts at the top-level module of the config, the cell of its
// design statement. The clause here reaches two levels down, to the leaf of
// m2 only: m1 and m2 are instances of the same module, and the leaf of m1
// keeps the cell of its own name through the default liblist work (33.4.1.2,
// 33.4.1.5), as does the instance next to m1 and m2.

module cfg4_leaf_a(output logic [7:0] y);
  assign y = 8'haa;
endmodule

module cfg4_leaf_b(output logic [7:0] y);
  assign y = 8'hbb;
endmodule

module cfg4_mid(output logic [7:0] y);
  cfg4_leaf_a leaf(y);
endmodule

module test_config_instance_deep_path;
  logic [7:0] y1, y2, y3;

  cfg4_mid m1(y1);
  cfg4_mid m2(y2);
  cfg4_leaf_a leaf(y3);

  initial #1 $display("m1.leaf=%h m2.leaf=%h leaf=%h", y1, y2, y3);
endmodule

config cfg4;
  design work.test_config_instance_deep_path;
  default liblist work;
  instance test_config_instance_deep_path.m2.leaf use work.cfg4_leaf_b;
endconfig
