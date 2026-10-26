/*
:name: test_illegal_dpi_export_duplicate
:description: Only one export declaration is allowed for a function in a scope, so a second export of the same function in the same scope is an error (IEEE 1800-2023 Section 35.7)
:tags: ch35
:type: elaboration
:lrm: 1800-2023 35.7 35.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function f is exported twice in the same module scope
:expected_stderr_regex: test_illegal_dpi_export_duplicate\.sv:25:
*/
// IEEE 1800-2023 §35.7: "Only one export declaration per function is allowed
// in a given scope." Both declarations here are in the scope of module
// test_illegal_dpi_export_duplicate, so the second one is an error. §35.4 adds
// that two functions in the same scope cannot share a linkage name.
//
// The 5.052 release of Verilator reports the second declaration at the line
// the test names. Icarus Verilog 13.0 has no DPI and rejects an export line
// for that reason, not for this rule, so it is not in :oracle:.

module test_illegal_dpi_export_duplicate;
  export "DPI-C" function f;
  export "DPI-C" function f;

  function int f();
    return 1;
  endfunction

  initial $display("f not rejected");
endmodule
