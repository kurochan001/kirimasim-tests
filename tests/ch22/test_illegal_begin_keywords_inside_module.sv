/*
:name: test_illegal_begin_keywords_inside_module
:description: `begin_keywords can only be specified outside a design element, so a `begin_keywords between the items of a module is an error (IEEE 1800-2023 Section 22.14)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.14
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: `begin_keywords appears inside the module test_illegal_begin_keywords_inside_module, which is a design element
:expected_stderr_regex: test_illegal_begin_keywords_inside_module\.sv:31:
*/
// IEEE 1800-2023 §22.14: `begin_keywords and `end_keywords can only be
// specified outside a design element (3.2). The first pair encloses the
// module kw_outside_ok and is legal. The second `begin_keywords stands
// between two items of a module and is the error; its `end_keywords
// follows the endmodule, outside the module, so the pair is complete and
// that directive is legal. The version 1800-2012 keeps logic a keyword, so
// the declarations after the directive mean the same under either keyword
// set.
// The design is accepted by Icarus Verilog 13.0 and Verilator 5.052.

`begin_keywords "1800-2012"
module kw_outside_ok;
endmodule
`end_keywords

module test_illegal_begin_keywords_inside_module;
  logic a = 1'b0;
`begin_keywords "1800-2012"  // illegal: inside the module
  logic b = 1'b1;
  kw_outside_ok u();
endmodule
`end_keywords
