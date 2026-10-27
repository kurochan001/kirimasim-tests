/*
:name: test_35_rest_dpi_class_formal
:description: A class type cannot be a formal argument of an import declaration, because class types cannot be passed across the DPI boundary at all (IEEE 1800-2023 Section 35.5.4)
:tags: ch35
:type: elaboration
:lrm: 1800-2023 35.5.4 35.5.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an import declaration has a formal argument of class type
:expected_stderr_regex: test_35_rest_dpi_class_formal\.sv:29:
*/
// IEEE 1800-2023 §35.5.4, footnote 27 of Syntax 35-1: class types cannot be
// passed at all as formals of an imported subroutine. §35.5.6 lists the
// permitted formal types, and a class type is not among them.
//
// The import below declares c_take with a formal of class type c_payload.
// The tool Verilator 5.052 rejects the declaration at elaboration with an
// error that names the class type, so the class-type prohibition is observed
// without a call. The declaration is never called, because the design is
// rejected.

module test_35_rest_dpi_class_formal;
  class c_payload;
    int value;
  endclass

  import "DPI-C" function void c_take(input c_payload p);   // class formal

  initial $display("accepted");
endmodule
