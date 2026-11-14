/*
:name: test_illegal_function_local_type_reference_without_var
:description: a variable declared in a function with a type reference as its data type needs the var keyword (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the local variable bad of the function plus_one is declared with the type reference type(a) without the var keyword
:expected_stderr_regex: test_illegal_function_local_type_reference_without_var\.sv:27:
*/
// IEEE 1800-2023 13.4 (Syntax 13-2, footnote 18): a type reference used in a
// variable declaration shall be preceded by var (and one used in a net
// declaration by a net type keyword). In the function plus_one, the local
// variable good is declared with var type(a) and is legal; bad is declared
// with type(a) alone. Without the declaration of bad and its use, the
// function returns a + 1 through good: plus_one(4'd6) prints 7.
// Icarus Verilog 13.0 does not parse type references and reports syntax
// errors on the legal declaration of good as well, so its error on the
// marked line does not count; release 5.054 of Verilator accepts the design.

module test_illegal_function_local_type_reference_without_var;
  function int plus_one(logic [3:0] a);
    var type(a) good;
    type(a) bad;   // illegal: no var before the type reference
    good = a + 4'd1;
    bad = good;
    return bad;
  endfunction
  initial $display("%0d", plus_one(4'd6));
endmodule
