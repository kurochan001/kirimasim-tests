/*
:name: test_illegal_anonymous_program_name_duplicates_package_item
:description: An item of an anonymous program shares the name space of its package, so a package function with the same name is a duplicate declaration (IEEE 1800-2023 Section 24.6)
:tags: ch24
:type: elaboration
:lrm: 1800-2023 24.6 26.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the package apd_pkg declares the function apd_scale, a name that its anonymous program already declares
:expected_stderr_regex: test_illegal_anonymous_program_name_duplicates_package_item\.sv:(?:28|33):
*/
// IEEE 1800-2023 §24.6: an anonymous program in a package or a compilation
// unit adds its items to the program-wide space without making a scope of
// its own; its items share the name space of the package. A declaration of
// the same name outside the anonymous program is therefore an error, even
// though code outside every program cannot reference the anonymous
// program's item. The anonymous program in apd_pkg declares apd_scale; the
// package then declares apd_scale again, which is the error, and apd_offset,
// a new name, which is legal. The error is reported at the second
// declaration, or at the first one as the other half of the pair.
// Icarus Verilog 13.0 reports a syntax error at the anonymous program, and
// the 5.052 release of Verilator does not support anonymous programs.

package apd_pkg;
  program;
    function automatic int apd_scale(int x);   // or here
      return 3 * x;
    endfunction
  endprogram

  function automatic int apd_scale(int x);   // illegal: apd_scale is already declared in apd_pkg
    return 4 * x;
  endfunction

  function automatic int apd_offset(int x);
    return x + 1;
  endfunction
endpackage

program test_illegal_anonymous_program_name_duplicates_package_item;
  import apd_pkg::*;
  initial $display("%0d %0d", apd_scale(2), apd_offset(2));
endprogram
