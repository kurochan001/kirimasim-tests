/*
:name: test_config_use_config_suffix
:description: When a config has the same name as a module in the same library, use lib.cell:config binds an instance to the config, while use lib.cell without the suffix binds it to the module (IEEE 1800-2023 Section 33.4.1.6)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.4.1.6 33.4.1.1 33.4.2 33.4.1.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_config_use_config_suffix.expected
*/
// IEEE 1800-2023 §33.4.1.6: if the lib.cell that a use clause names is a
// config with the same name as a module in the same library, the suffix
// :config selects the config. §33.4.1.1: a design statement names a cell that
// is not a configuration, and the design may have the same name as a config.
// The module cfgsx_mid and the config cfgsx_mid are both in work; the config
// configures the hierarchy of the module cfgsx_mid and binds its leaf to
// cfgsx_leaf_b. The config cfg binds m1 with use work.cfgsx_mid, the module,
// whose leaf stays cfgsx_leaf_a, and m2 with use work.cfgsx_mid:config, the
// config, so the leaf of m2 becomes cfgsx_leaf_b (33.4.2, 33.4.1.3).

module cfgsx_leaf_a(output logic [7:0] y);
  assign y = 8'haa;
endmodule

module cfgsx_leaf_b(output logic [7:0] y);
  assign y = 8'hbb;
endmodule

module cfgsx_mid(output logic [7:0] y);
  cfgsx_leaf_a leaf(y);
endmodule

module test_config_use_config_suffix;
  logic [7:0] y1, y2;

  cfgsx_mid m1(y1);
  cfgsx_mid m2(y2);

  initial #1 $display("m1 leaf: %h, m2 leaf: %h", y1, y2);
endmodule

config cfgsx_mid;
  design work.cfgsx_mid;
  default liblist work;
  instance cfgsx_mid.leaf use work.cfgsx_leaf_b;
endconfig

config cfg;
  design work.test_config_use_config_suffix;
  default liblist work;
  instance test_config_use_config_suffix.m1 use work.cfgsx_mid;
  instance test_config_use_config_suffix.m2 use work.cfgsx_mid:config;
endconfig
