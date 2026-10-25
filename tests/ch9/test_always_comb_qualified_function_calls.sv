/*
:name: test_always_comb_qualified_function_calls
:description: an always_comb is sensitive to what a package function, a static class method called with :: and a function called by a hierarchical name read, as for any other called function (IEEE 1800-2023 Section 9.2.2.2.1)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_comb_qualified_function_calls.expected
*/
// IEEE 1800-2023 §9.2.2.2.1: function calls by a hierarchical name, calls of
// package functions and calls of static methods with the class scope
// resolution operator are analyzed like other function calls, so the
// variables they read are in the implicit sensitivity of always_comb.
//
// The block adds the results of p::pf(), K::sf() and u.hf(), which read the
// package variable pv, the static property sv and the variable hv of the
// instance u. None of the three is passed as an argument. Each change of
// one of them runs the block again and changes y.

package test_always_comb_qualified_function_calls_pkg;
  int pv = 1;
  function int pf();
    return pv;
  endfunction
endpackage

module test_always_comb_qualified_function_calls_sub;
  int hv = 100;
  function int hf();
    return hv;
  endfunction
endmodule

module test_always_comb_qualified_function_calls;
  import test_always_comb_qualified_function_calls_pkg::*;

  class K;
    static int sv = 10;
    static function int sf();
      return sv;
    endfunction
  endclass

  test_always_comb_qualified_function_calls_sub u ();

  int y;

  always_comb begin
    y = test_always_comb_qualified_function_calls_pkg::pf() + K::sf() + u.hf();
  end

  initial begin
    #1 $display("start:     y=%0d", y);
    pv = 2;
    #1 $display("pv = 2:    y=%0d", y);
    K::sv = 20;
    #1 $display("sv = 20:   y=%0d", y);
    u.hv = 200;
    #1 $display("hv = 200:  y=%0d", y);
  end
endmodule
