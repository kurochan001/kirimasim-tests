/*
:name: test_package_import_into_package
:description: A package that imports another package uses the imported parameter and type in its own parameter, typedef and function (IEEE 1800-2023 Section 26.3)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.3 26.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_import_into_package.expected
*/
// IEEE 1800-2023 §26.3: the items that a package imports are visible inside
// that package, so derived_pkg can use the parameter W, the type word_t and
// the function inc of base_pkg in its own localparam, typedef and function.
// A module that imports derived_pkg sees those items; it does not see W or inc
// itself, since derived_pkg does not export them (26.6).

package ip_base;
  parameter int W = 8;
  typedef logic [W-1:0] word_t;

  function automatic int inc(int x);
    return x + 1;
  endfunction
endpackage

package ip_derived;
  import ip_base::*;

  localparam int HALF = W / 2;
  typedef word_t half_t;

  function automatic int inc_twice(int x);
    return inc(inc(x));
  endfunction
endpackage

module test_package_import_into_package;
  import ip_derived::*;

  half_t h;
  int t;

  initial begin
    h = 8'hA5;
    t = inc_twice(5);
    $display("HALF=%0d h=%h inc_twice=%0d", HALF, h, t);
  end
endmodule
