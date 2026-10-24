/*
:name: test_package_declaration_forms
:description: a package declaration with an attribute, a lifetime, timeunit and timeprecision first, an import and an export, functions, an anonymous program, and a closing label (IEEE 1800-2023 Section 26.2)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.2 24.6 26.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_declaration_forms.expected
*/
// IEEE 1800-2023 §26.2, Syntax 26-1: a package declaration may start with
// attribute instances and a lifetime before its name, may begin with a
// timeunits declaration, contains declarations, anonymous programs and
// package exports, and ends with endpackage and an optional label that
// repeats the name. With the lifetime automatic, the functions of the
// package are automatic unless declared otherwise, so a recursive function
// keeps a separate argument and local variable in each call.
// §24.6: the items of an anonymous program in a package are part of the
// program-wide space, in the name space of the package, and programs can
// use them. Program pf_user imports pf_form and calls the recursive
// function fact, the exported name B and the function prog_twice of the
// anonymous program. Neither Icarus Verilog 13.0 (attributes on a package,
// anonymous programs) nor the 5.052 release of Verilator (anonymous
// programs) compiles the test.

`timescale 1ns/1ns

package pf_base;
  localparam int B = 3;
endpackage

(* origin = "test" *) package automatic pf_form;
  timeunit 1ns;
  timeprecision 1ns;
  import pf_base::B;
  export pf_base::B;

  function int fact(int n);
    int r;
    if (n <= 1) return 1;
    r = n * fact(n - 1);
    return r;
  endfunction

  program;
    function int prog_twice(int v);
      return 2 * v;
    endfunction
  endprogram
endpackage : pf_form

program pf_user;
  import pf_form::*;
  initial $display("fact(5)=%0d B=%0d prog_twice(4)=%0d", fact(5), B, prog_twice(4));
endprogram
