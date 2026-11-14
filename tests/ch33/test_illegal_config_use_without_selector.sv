/*
:name: test_illegal_config_use_without_selector
:description: a use clause of a config stands alone, without the instance or cell clause that selects what it binds (IEEE 1800-2023 Section 33.4.1.6)
:tags: ch33
:type: elaboration
:lrm: 1800-2023 33.4.1.6
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the config rule statement is a use clause with no instance or cell selection clause before it
:expected_stderr_regex: test_illegal_config_use_without_selector\.sv:40:
*/
// IEEE 1800-2023 §33.4.1.6: a use clause gives the library and cell that a
// selected instance or cell is bound to, and it can only be used together
// with an instance or a cell selection clause (Syntax 33-4: inst_clause
// use_clause or cell_clause use_clause). The rule below has the use clause
// alone. The same rule written as
// "instance test_illegal_config_use_without_selector.u use work.<cell>;" is
// legal.
//
// Icarus Verilog 13.0 and the 5.054 release of Verilator report a syntax
// error at the use clause; the 5.054 release says that it expects an instance
// or a cell clause there. Both accept the config with the instance clause
// (Icarus Verilog 13.0 then skips the config, which it does not support), so
// the error is the one for the missing selection clause.

module test_illegal_config_use_without_selector_a;
endmodule

module test_illegal_config_use_without_selector_b;
endmodule

module test_illegal_config_use_without_selector;
  test_illegal_config_use_without_selector_a u();
endmodule

config test_illegal_config_use_without_selector_cfg;
  design work.test_illegal_config_use_without_selector;
  use work.test_illegal_config_use_without_selector_b;   // illegal: no selector
endconfig
