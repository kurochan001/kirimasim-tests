/*
:name: test_illegal_config_cell_library_liblist
:description: A cell clause with a library name cannot take a liblist clause (IEEE 1800-2023 Section 33.4.1.4)
:tags: ch33
:type: elaboration
:lrm: 1800-2023 33.4.1.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the cell clause names a library and has a liblist clause
:expected_stderr_regex: test_illegal_config_cell_library_liblist\.sv:27:
*/
// IEEE 1800-2023 §33.4.1.4: when a cell selection clause names a library, its
// expansion clause cannot be a library list; work.cfgx3_leaf with liblist is an
// error, while a cell clause without the library could take one.

module cfgx3_leaf;
endmodule

module test_illegal_config_cell_library_liblist;
  cfgx3_leaf u();
endmodule

config cfgx3;
  design work.test_illegal_config_cell_library_liblist;
  cell work.cfgx3_leaf liblist work;   // illegal: library and liblist
endconfig
