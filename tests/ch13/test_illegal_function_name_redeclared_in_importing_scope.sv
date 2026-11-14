/*
:name: test_illegal_function_name_redeclared_in_importing_scope
:description: no other object can be declared with the name of a function in a scope that imports the function explicitly (IEEE 1800-2023 Section 13.4.1)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module imports the function doubled of the package doubled_pkg explicitly and then declares a variable also named doubled
:expected_stderr_regex: test_illegal_function_name_redeclared_in_importing_scope\.sv:(32|33):
*/
// IEEE 1800-2023 §13.4.1: it is illegal to declare another object with the
// same name as a function in a scope into which the function is explicitly
// imported. The module imports doubled from doubled_pkg by name and then
// declares the int variable doubled (§26.3 forbids the same pair of an
// explicit import and a local declaration of its name). Without the variable
// the design is legal and prints the result of the call doubled(3), 6.
// A tool can report the error at the variable or at the import that it
// collides with. Icarus Verilog 13.0 reports at the variable that the name
// is already imported from the package. The 5.054 release of Verilator
// accepts the declaration and reports only the later call, at another line.

package doubled_pkg;
  function int doubled(input int a);
    return 2 * a;
  endfunction
endpackage

module test_illegal_function_name_redeclared_in_importing_scope;
  import doubled_pkg::doubled;
  int doubled;   // illegal: another object with the name of the imported function
  initial $display("%0d", doubled(3));
endmodule
