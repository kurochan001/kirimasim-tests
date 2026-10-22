/*
:name: test_builtin_method_forms_after_mutation
:description: Parenthesized and argumentless forms of builtin methods observe the same updated object (IEEE 1800-2023 Section 5.13)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_builtin_method_forms_after_mutation.expected
*/
// IEEE 1800-2023 5.13: The optional parentheses rule also applies after
// resizing an array and changing a string, rather than just to initial values.
// Oracle checks: Icarus Verilog 13.0 does not build this case.

module test_builtin_method_forms_after_mutation;
  int a[];
  string s = "abcde";
  initial begin
    a = new[4];
    $display("array=%0d,%0d string=%0d,%0d", a.size, a.size(), s.len, s.len());
    a.delete(); s = "";
    $display("empty=%0d,%0d,%0d,%0d", a.size(), a.size, s.len(), s.len);
  end
endmodule
