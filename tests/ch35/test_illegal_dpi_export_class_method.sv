/*
:name: test_illegal_dpi_export_class_method
:description: A class member function cannot be exported to foreign code, even from the class scope where it is defined (IEEE 1800-2023 Section 35.7)
:tags: ch35
:type: elaboration
:lrm: 1800-2023 35.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the export declaration in class cm_child exports the class member function m
:expected_stderr_regex: test_illegal_dpi_export_class_method\.sv:21:
*/
// IEEE 1800-2023 §35.7: an export declaration may occur only in the scope in
// which the exported function is defined, but one restriction applies to the
// kind of function: class member functions cannot be exported, though every
// other SystemVerilog function can. The class cm_child holds an export
// declaration for its member function m, which the rule forbids.

class cm_child;
  export "DPI-C" function m;   // illegal: m is a class member function

  function int m();
    return 1;
  endfunction
endclass

// Icarus Verilog 13.0 has no DPI and rejects the export line for that reason,
// so it is not in :oracle:. Verilator 5.052 rejects it for this rule.

module test_illegal_dpi_export_class_method;
  cm_child o;

  initial $display("not rejected");
endmodule
