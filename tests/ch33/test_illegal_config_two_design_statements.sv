/*
:name: test_illegal_config_two_design_statements
:description: A config has exactly one design statement (IEEE 1800-2023 Section 33.4.1.1)
:tags: ch33
:type: elaboration
:lrm: 1800-2023 33.4.1.1 33.4.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the config has two design statements
:expected_stderr_regex: test_illegal_config_two_design_statements\.sv:27:
*/
// IEEE 1800-2023 §33.4.1.1: a config shall have one and only one design
// statement; several top-level cells are listed in that one statement.

module cfgd2_a;
  initial $display("a");
endmodule

module cfgd2_b;
  initial $display("b");
endmodule

config cfgd2;
  design work.cfgd2_a;
  design work.cfgd2_b;   // illegal: second design statement
endconfig
