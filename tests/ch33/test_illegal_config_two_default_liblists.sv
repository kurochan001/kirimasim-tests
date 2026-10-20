/*
:name: test_illegal_config_two_default_liblists
:description: A config cannot have two default clauses with a liblist (IEEE 1800-2023 Section 33.4.1.2)
:tags: ch33
:type: elaboration
:lrm: 1800-2023 33.4.1.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the config has two default liblist clauses
:expected_stderr_regex: test_illegal_config_two_default_liblists\.sv:(23|24):
*/
// IEEE 1800-2023 §33.4.1.2: for an expansion clause other than use, a config
// can have only one default clause that gives it; this config gives the liblist
// in two default clauses. A tool can report either clause.

module test_illegal_config_two_default_liblists;
endmodule

config cfgx2;
  design work.test_illegal_config_two_default_liblists;
  default liblist work;   // illegal: the first default liblist
  default liblist work;   // illegal: and a second one
endconfig
