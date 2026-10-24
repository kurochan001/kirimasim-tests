/*
:name: test_illegal_automatic_data_declaration_in_module
:description: A data declaration outside a procedural context cannot use the keyword automatic, while automatic in a declaration inside a task is legal (IEEE 1800-2023 Section 25.9)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module item declaration of count uses the keyword automatic
:expected_stderr_regex: test_illegal_automatic_data_declaration_in_module\.sv:24:
*/
// IEEE 1800-2023 §25.9, footnote 14 of Syntax 25-3: in a data_declaration that
// is not within a procedural context, it shall be illegal to use the
// automatic keyword. The variable tmp of the task bump is declared automatic
// inside the task, which is legal; the module item count is declared
// automatic.
// Icarus Verilog 13.0 stops with "sorry" (a lifetime override is not
// supported), which does not count.

module test_illegal_automatic_data_declaration_in_module;
  int total = 0;
  automatic int count = 0;   // illegal: automatic outside a procedural context
  task bump();
    automatic int tmp = 1;
    total += tmp;
  endtask
  initial begin
    bump();
    $display("%0d", total);
  end
endmodule
