/*
:name: test_constant_function_call_declaration_places
:description: A call with constant arguments is evaluated at elaboration as a constant function call when the function is declared in the calling module, in a package or in $unit, or is a static method of a class there, also of a parameterized class (IEEE 1800-2023 Section 13.4.3)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.3 13.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constant_function_call_declaration_places.expected
*/
// IEEE 1800-2023 §13.4.3: a constant function call is a call of a constant
// function with constant arguments whose declaration is local to the
// calling design element or is in a package or $unit; calls of static
// methods of classes declared there, including parameterized ones (13.8),
// with constant arguments are constant function calls too.
//
// Each kind of function gives a localparam, and each localparam sets the
// packed width of a variable, which needs a constant: a module function,
// a package function, a $unit function, a static method of a class in the
// package, and a static method of a parameterized class specialized with
// K = 5. $bits of the variables shows the values computed at elaboration.

function automatic int unit_triple(int x);
  return 3 * x;
endfunction

package cf_pkg;
  function automatic int pkg_square(int x);
    return x * x;
  endfunction

  class Calc;
    static function int add_one(int x);
      return x + 1;
    endfunction
  endclass

  class Scale #(int K = 2);
    static function int times(int x);
      return K * x;
    endfunction
  endclass
endpackage

module test_constant_function_call_declaration_places;
  function automatic int local_double(int x);
    return 2 * x;
  endfunction

  localparam int A = local_double(3);
  localparam int B = cf_pkg::pkg_square(4);
  localparam int C = unit_triple(5);
  localparam int D = cf_pkg::Calc::add_one(6);
  localparam int E = cf_pkg::Scale#(5)::times(3);

  logic [A-1:0] va;
  logic [B-1:0] vb;
  logic [C-1:0] vc;
  logic [D-1:0] vd;
  logic [E-1:0] ve;

  initial begin
    $display("module function:        A=%0d bits=%0d", A, $bits(va));
    $display("package function:       B=%0d bits=%0d", B, $bits(vb));
    $display("$unit function:         C=%0d bits=%0d", C, $bits(vc));
    $display("static class method:    D=%0d bits=%0d", D, $bits(vd));
    $display("parameterized class K=5: E=%0d bits=%0d", E, $bits(ve));
  end
endmodule
