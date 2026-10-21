/*
:name: test_package_explicit_import_hides_wildcard
:description: An explicit import of a name takes precedence over a wildcard import that provides the same name from another package (IEEE 1800-2023 Section 26.3)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_explicit_import_hides_wildcard.expected
*/
// IEEE 1800-2023 §26.3: a wildcard import makes the names of a package visible,
// but an explicit import of a name that another package also declares selects
// that package's item. Both packages here declare VALUE and who(); the module
// imports both from ew_b, so it sees 2 rather than 1, without a reference that
// two wildcard imports provide (26.3). Verilator 5.052 lets the wildcard
// import decide and prints 1, so the expected output is recorded with Icarus
// Verilog 13.0.

package ew_a;
  parameter int VALUE = 1;
  function automatic int who();
    return 1;
  endfunction
endpackage

package ew_b;
  parameter int VALUE = 2;
  function automatic int who();
    return 2;
  endfunction
endpackage

module test_package_explicit_import_hides_wildcard;
  import ew_a::*;
  import ew_b::VALUE;
  import ew_b::who;

  initial $display("VALUE=%0d who=%0d", VALUE, who());
endmodule
