/*
:name: test_illegal_config_instance_inside_other_config
:description: An instance clause cannot name an instance inside a hierarchy that another config configures (IEEE 1800-2023 Section 33.4.2)
:tags: ch33
:type: elaboration
:lrm: 1800-2023 33.4.2 33.4.1.3 33.4.1.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the top config names an instance below one that a sub-config configures
:expected_stderr_regex: test_illegal_config_instance_inside_other_config\.sv:41:
*/
// IEEE 1800-2023 §33.4.2: an instance can be configured by another config
// with use ...:config, which then decides its whole subhierarchy. It shall be
// an error for an instance clause to give a path into a hierarchy that
// another config specifies.
// Icarus Verilog 13.0 skips config declarations and accepts the design
// (docs/simulator-differences.md).

module cfgio_leaf;
  initial $display("leaf %m");
endmodule

module cfgio_mid;
  cfgio_leaf l();
endmodule

module cfgio_top;
  cfgio_mid m();
endmodule

config cfgio_sub;
  design work.cfgio_mid;
  default liblist work;
endconfig

config cfgio;
  design work.cfgio_top;
  instance cfgio_top.m use work.cfgio_sub:config;
  instance cfgio_top.m.l use work.cfgio_leaf;   // illegal: inside the hierarchy of cfgio_sub
endconfig
