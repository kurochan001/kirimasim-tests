/*
:name: test_package_import_export_item_lists
:description: import declarations with one item and with a list of explicit and wildcard items, export declarations with a list of items and with *::*, and an import and a typedef among the declarations of a function, observed through the values that the imported and exported names reach (IEEE 1800-2023 Sections 26.3, 26.6, A.2.1.3)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.3 26.6 6.18 A.2.1.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_import_export_item_lists.expected
*/
// IEEE 1800-2023 A.2.1.3: an import declaration is import, one or more
// items separated by commas (package::name or package::*) and a semicolon;
// an export declaration is export *::*; or export with such a list. A data
// declaration may also be a type declaration or an import declaration, so
// both can stand among the declarations of a function (A.10 note 15 forbids
// an import only directly in a class).
// - §26.6: p_mid exports a1, which it imports explicitly, and b1, which its
//   wildcard import only offers; the export counts as a reference and
//   imports it. p_all exports with *::* what it actually imported: a2 and
//   c1, which all_get uses. The module imports these names from p_mid and
//   p_all; an import through an export is the original declaration, so the
//   write a1 = 50 is seen as p_a::a1.
// - §26.3: the explicit import of p_c::c2 in local_view hides the c2 of the
//   module (99) inside the function, and its local typedef tri_t has 3 bits,
//   so t = 7 wraps to 0 after += 1: 32 * 100 + 3 * 10 + 0.

package p_a;
  int a1 = 11, a2 = 12;
  function automatic int twice(int v);
    return 2 * v;
  endfunction
endpackage

package p_b;
  int b1 = 21, b2 = 22;
endpackage

package p_c;
  int c1 = 31, c2 = 32;
endpackage

package p_mid;
  import p_a::a1, p_a::twice, p_b::*;
  export p_a::a1, p_b::b1;
  function automatic int mid_sum();
    return twice(a1) + b2;
  endfunction
endpackage

package p_all;
  import p_c::*;
  import p_a::a2;
  export *::*;
  function automatic int all_get();
    return c1 + a2;
  endfunction
endpackage

module test_package_import_export_item_lists;
  import p_mid::a1, p_mid::b1, p_mid::mid_sum;
  import p_all::*;
  int c2 = 99;

  function automatic int local_view();
    import p_c::c2;
    typedef bit [2:0] tri_t;
    tri_t t = 3'd7;
    t += 1;
    return c2 * 100 + $bits(tri_t) * 10 + t;
  endfunction

  initial begin
    $display("a1=%0d b1=%0d mid_sum=%0d", a1, b1, mid_sum());
    $display("c1=%0d a2=%0d all_get=%0d", c1, a2, all_get());
    $display("local_view=%0d c2=%0d", local_view(), c2);
    a1 = 50;
    $display("p_a::a1=%0d a1=%0d", p_a::a1, a1);
  end
endmodule
