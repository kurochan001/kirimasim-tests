/*
:name: test_config_name_disambiguation_config_suffix
:description: When a config has the same name as a module in the same library, use lib.cell names the module and use lib.cell:config names the config (IEEE 1800-2023 Section 33.2.1)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.2.1 33.4.1.6 33.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_config_name_disambiguation_config_suffix.expected
*/
// IEEE 1800-2023 §33.2.1: the lib.cell notation may carry the :config suffix,
// which shall be used explicitly when a config has the same name as a
// module or primitive. Module ccn_mid and config ccn_mid share the name and
// both live in the library work (33.3.1). In the config ccn, the instance m1
// is bound with use work.ccn_mid, the module, so its leaf_a stays; the
// instance m2 is bound with use work.ccn_mid:config, the config, whose rule
// replaces leaf_a by leaf_b (33.4.2), so only m2 shows bb.
//
// Icarus Verilog 13.0 skips config declarations, and Verilator 5.052 rejects
// the hierarchical config rule, so :oracle: names the standard alone.

module ccn_leaf_a(output logic [7:0] y);
  assign y = 8'ha1;
endmodule

module ccn_leaf_b(output logic [7:0] y);
  assign y = 8'hb2;
endmodule

module ccn_mid(output logic [7:0] y);
  ccn_leaf_a leaf(y);
endmodule

module test_config_name_disambiguation_config_suffix;
  logic [7:0] y1, y2;

  ccn_mid m1(y1);
  ccn_mid m2(y2);

  initial #1 $display("m1=%h m2=%h", y1, y2);
endmodule

config ccn_mid;
  design work.ccn_mid;
  default liblist work;
  instance ccn_mid.leaf use work.ccn_leaf_b;
endconfig

config ccn;
  design work.test_config_name_disambiguation_config_suffix;
  default liblist work;
  instance test_config_name_disambiguation_config_suffix.m1 use work.ccn_mid;
  instance test_config_name_disambiguation_config_suffix.m2 use work.ccn_mid:config;
endconfig
