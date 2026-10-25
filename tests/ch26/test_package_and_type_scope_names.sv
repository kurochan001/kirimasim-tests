/*
:name: test_package_and_type_scope_names
:description: A package scope made of a package name and a double colon, or of $unit and a double colon, names the variable, parameter, function, class, type and static class property inside it, and a class scope names a type and a property of that class; each reference gives its value or width (IEEE 1800-2023 Sections 26.3, 26.6 and 6.18)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.3 26.6 6.18 A.9.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_and_type_scope_names.expected
*/
// IEEE 1800-2023 A.9.3: a package scope is a package identifier and a double
// colon or $unit and a double colon; a package-scoped type identifier has a
// package scope or a class scope, and a ps_class_identifier has an optional
// package scope. §26.3: the items of a package are visible through its name,
// and a name declared at compilation-unit scope is visible through $unit.
// §26.6: a package can hold variables, parameters, functions, classes and
// types. §6.18: a typedef gives a type name; one in a class is named through
// the class scope.
//
// pkg1::x is set to 6, pkg1::P is 4 and pkg1::f(3) is 6. nib_t is 4 bits
// wide, the nested class type inner_t is 32 bits and the module class c2 has
// the 2-bit type t2. The static property pkg1::c::s is 9 and the cast
// inner_t'(5) is 5. The compilation-unit variable uvar is 7.
//
// Icarus Verilog 13.0 cannot declare a variable of a package-scoped class
// type; Verilator 5.052 produces this output.

`timescale 1ns/1ns

int uvar = 7;

package pkg1;
  int x = 5;
  parameter int P = 4;
  typedef logic [3:0] nib_t;

  class c;
    static int s = 9;
    typedef int inner_t;
  endclass

  function automatic int f(int a);
    return a * 2;
  endfunction
endpackage

class c2;
  typedef logic [1:0] t2;
endclass

module test_package_and_type_scope_names;
  pkg1::c obj;

  initial begin
    pkg1::x = 6;
    obj = new;
    $display("scope %0d %0d %0d", pkg1::x, pkg1::P, pkg1::f(3));
    $display("type %0d %0d %0d", $bits(pkg1::nib_t), $bits(pkg1::c::inner_t),
             $bits(c2::t2));
    $display("class %0d %0d", pkg1::c::s, pkg1::c::inner_t'(5));
    $display("unit %0d", $unit::uvar);
  end
endmodule
