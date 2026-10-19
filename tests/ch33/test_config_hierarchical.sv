/*
:name: test_config_hierarchical
:description: an instance clause can bind an instance to another configuration with use lib.cell:config; the design statement of that configuration gives the cell of the instance, and its own rules configure the instances below it, while the rest of the design follows the outer configuration (IEEE 1800-2023 Section 33.4.2)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.4.2 33.4.1.3 33.4.1.6 33.4.1.1 33.4.1.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_config_hierarchical.expected
*/
// IEEE 1800-2023 §33.4.2: "instance path use lib.cell:config" binds the
// instance to the hierarchy that the configuration cell describes: its design
// statement (§33.4.1.1) gives the cell for the instance, and its rules apply
// to all instances below it. Here cfg is the configuration of the whole
// design; m2 is bound to the configuration mid_cfg, which binds the leaf of
// cfg_mid to cfg_leaf_b. m1 is configured by cfg alone, whose default
// liblist work (§33.4.1.5) binds its leaf to cfg_leaf_a, the cell its
// instance names (§33.4.1.3, §33.4.1.6).

module cfg_leaf_a(output logic [7:0] y);
  assign y = 8'haa;
endmodule

module cfg_leaf_b(output logic [7:0] y);
  assign y = 8'hbb;
endmodule

module cfg_mid(output logic [7:0] y);
  cfg_leaf_a leaf(y);
endmodule

module test_config_hierarchical;
  logic [7:0] y1, y2;

  cfg_mid m1(y1);
  cfg_mid m2(y2);

  initial #1 $display("m1 leaf: %h, m2 leaf: %h", y1, y2);
endmodule

config mid_cfg;
  design work.cfg_mid;
  default liblist work;
  instance cfg_mid.leaf use work.cfg_leaf_b;
endconfig

config cfg;
  design work.test_config_hierarchical;
  default liblist work;
  instance test_config_hierarchical.m2 use work.mid_cfg:config;
endconfig
