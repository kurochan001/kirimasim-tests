/*
:name: test_extern_method_class_scope_current_specialization
:description: in the out-of-block body of a method of a parameterized class, the unadorned class name before :: names the parameters of the specialization that runs the method, not the default specialization (IEEE 1800-2023 Section 8.25.1)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.25.1 8.24
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_extern_method_class_scope_current_specialization.expected
*/
// IEEE 1800-2023 §8.25.1: in an out-of-block declaration of a method of a
// parameterized class (8.24), the class scope operator with the plain class
// name refers to the name as if the reference were written inside the class;
// it does not select the default specialization.
//
// scaler has a value parameter K (default 2) and a type parameter W (default
// byte). The bodies of scale, k_value and w_bits are written outside the
// class. scale declares a local K, so the parameter has to be written
// scaler::K there; its return type is scaler::W. Each specialization has to
// use its own K and W: scaler#(5, shortint)::scale(30) is 30*5 + 100 = 250
// returned as a 16-bit shortint, and scaler#(.W(int))::scale(1000) is
// 1000*2 + 100 = 2100 returned as an int. If scaler:: meant the default
// specialization, those would be computed with K = 2 and returned as a byte.
// Icarus Verilog 13.0 does not compile the parameterized class.

module test_extern_method_class_scope_current_specialization;
  class scaler #(int K = 2, type W = byte);
    extern static function W scale(int v);
    extern static function int k_value();
    extern static function int w_bits();
  endclass

  function scaler::W scaler::scale(int v);
    int K;
    K = 100;
    return v * scaler::K + K;
  endfunction

  function int scaler::k_value();
    return scaler::K;
  endfunction

  function int scaler::w_bits();
    return $bits(scaler::W);
  endfunction

  initial begin
    $display("scaler#(): scale(3)=%0d K=%0d bits(W)=%0d", scaler#()::scale(3),
             scaler#()::k_value(), scaler#()::w_bits());
    $display("scaler#(5, shortint): scale(30)=%0d K=%0d bits(W)=%0d",
             scaler#(5, shortint)::scale(30), scaler#(5, shortint)::k_value(),
             scaler#(5, shortint)::w_bits());
    $display("scaler#(.W(int)): scale(1000)=%0d K=%0d bits(W)=%0d",
             scaler#(.W(int))::scale(1000), scaler#(.W(int))::k_value(),
             scaler#(.W(int))::w_bits());
  end
endmodule
