/*
:name: test_config_use_and_liblist_rules
:description: Two instance clauses for the same instance, one with a use clause and one with a liblist clause, both take effect in either order: the use clause binds the instance and the liblist clause gives the liblist for the instances below it (IEEE 1800-2023 Section 33.4.1.6)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.4.1.6 33.4.1.5 33.4.1.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_config_use_and_liblist_rules.expected
*/
// IEEE 1800-2023 §33.4.1.6: a use clause gives the exact library and cell of
// the selected instance and leaves the current liblist as it is, so a config
// can give one rule with the binding and another rule with the liblist for the
// same instance. §33.4.1.5: the liblist is searched for the instances below,
// which inherit it. §33.3.1: with no library map file, every cell of this test
// is in the library work.
//
// The library ulr_none holds no cell, and the default liblist names only it.
// For m1 the config gives the use rule first and the liblist rule second, for
// m2 the other way round. In both, the use rule binds the instance to
// work.ulr_mid_b instead of ulr_mid_a, the cell its instantiation names, and
// the liblist rule lets its leaf be found in work. Each mid cell puts its own
// digit in the high half of its output, so both lines print b1. A tool that
// let the later rule replace the earlier one would bind m1 to ulr_mid_a and
// print a1, or leave the leaf of m2 with the default liblist, where no cell
// ulr_leaf can be found.

module ulr_leaf(output logic [3:0] y);
  assign y = 4'h1;
endmodule

module ulr_mid_a(output logic [7:0] y);
  logic [3:0] low;

  ulr_leaf leaf(low);
  assign y = {4'ha, low};
endmodule

module ulr_mid_b(output logic [7:0] y);
  logic [3:0] low;

  ulr_leaf leaf(low);
  assign y = {4'hb, low};
endmodule

module test_config_use_and_liblist_rules;
  logic [7:0] y1, y2;

  ulr_mid_a m1(y1);
  ulr_mid_a m2(y2);

  initial #1 $display("m1=%h m2=%h", y1, y2);
endmodule

config ulr_cfg;
  design work.test_config_use_and_liblist_rules;
  default liblist ulr_none;
  instance test_config_use_and_liblist_rules.m1 use work.ulr_mid_b;
  instance test_config_use_and_liblist_rules.m1 liblist work;
  instance test_config_use_and_liblist_rules.m2 liblist work;
  instance test_config_use_and_liblist_rules.m2 use work.ulr_mid_b;
endconfig
