/*
:name: test_param_without_default_not_implicit_top
:description: a parameter declared without a default gets its value only from an override, and a module with such a parameter that nothing instantiates is not made a top-level instance (IEEE 1800-2023 Section 6.20.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.1 23.3.1 8.25
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_param_without_default_not_implicit_top.expected
*/
// IEEE 1800-2023 §6.20.1: in a parameter port list the default value may be
// left out; the parameter then has no default, every instance or class
// specialization has to give a value, and a tool shall not instantiate such
// a design element implicitly. pwd_child gets P from its instance and the
// class pwd_c gets N from its specialization (§8.25). pwd_unused is not
// instantiated anywhere; without the rule it would be a top-level module
// (§23.3.1), but since Q has no default it is not elaborated, so its line
// is not printed.
// Icarus Verilog 13.0 does not parse the class parameter port list without
// defaults (syntax error). Verilator 5.052 elaborates pwd_unused as a
// top-level module and stops with an error that Q is never given a value.

module pwd_child #(parameter int P) ();
  initial $display("%m: P=%0d", P);
endmodule

module pwd_unused #(parameter int Q) ();
  initial $display("pwd_unused: Q=%0d", Q);
endmodule

class pwd_c #(int N, type T);
  static function int get();
    T t;
    return N * 100 + $bits(t);
  endfunction
endclass

module test_param_without_default_not_implicit_top;
  pwd_child #(.P(5)) c ();
  initial #1 $display("class: %0d", pwd_c#(3, byte)::get());
endmodule
