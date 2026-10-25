/*
:name: test_package_import_in_method_body_and_enclosing_scope
:description: Package imports placed in method bodies of a class and in the module that encloses the class, not directly in the class, make the package items visible only in those scopes: each method sees the items of its own import before a class property of the same name, and a method without an import sees the property (IEEE 1800-2023 Section 26.3)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.3 8.6 A.2.1.3 A.10
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_import_in_method_body_and_enclosing_scope.expected
*/
// IEEE 1800-2023 §26.3 with footnote 15 of A.10: an import is not allowed
// directly in a class scope, but it is a data declaration that can be placed
// in the body of a method or in the scope that encloses the class. An import
// makes the package items visible in the scope where it is written; a name is
// looked up first in the current scope, including its wildcard imports, and
// then in the enclosing scopes.
//
// The module imports ip_a::six_t, so the class property v has 6 bits.
// The class has its own property SCALE = 100.
//   with_a imports ip_a::* : f(2) * SCALE = 3 * 4      = 12
//   with_b imports ip_b::SCALE: 2 * SCALE = 2 * 7      = 14
//   plain has no import:    2 * SCALE = 2 * 100        = 200 (the property)

package ip_a;
  localparam int SCALE = 4;
  typedef bit [5:0] six_t;

  function automatic int f(int x);
    return x + 1;
  endfunction
endpackage

package ip_b;
  localparam int SCALE = 7;
endpackage

module test_package_import_in_method_body_and_enclosing_scope;
  import ip_a::six_t;

  class Calc;
    six_t v = 6'h3F;
    int SCALE = 100;

    function int with_a(int x);
      import ip_a::*;
      return f(x) * SCALE;
    endfunction

    function int with_b(int x);
      import ip_b::SCALE;
      return x * SCALE;
    endfunction

    function int plain(int x);
      return x * SCALE;
    endfunction
  endclass

  initial begin
    Calc c;
    c = new;
    $display("v=%0d bits=%0d", c.v, $bits(c.v));
    $display("with_a=%0d with_b=%0d plain=%0d", c.with_a(2), c.with_b(2), c.plain(2));
  end
endmodule
