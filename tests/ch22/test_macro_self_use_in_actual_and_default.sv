/*
:name: test_macro_self_use_in_actual_and_default
:description: An actual argument of a macro use, and the default of a formal argument, may contain a use of the same macro; this is not a recursive macro, and the nested uses expand to their own values (IEEE 1800-2023 Section 22.5.1)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_macro_self_use_in_actual_and_default.expected
*/
// IEEE 1800-2023 §22.5.1: a macro that expands to text containing another use
// of itself is an error, but an actual argument or a default may contain a use
// of the macro itself. A macro use in an actual argument or in a default is
// expanded only after it has been substituted into the outer macro text.
// INC adds 1 to its argument, whose default is a use of INC with the actual 1,
// so INC() is ((INC(1)) + 1), which is 3. INC(10) does not use the default.
// The first line nests INC three times in actual arguments of INC, and SUM
// twice and three levels deep in its two actual arguments, the commas inside
// the inner uses being in parentheses. The last line gives INC() as the
// actual of INC, which uses the default inside an actual argument.
// A tool that takes these nested uses for a recursive macro rejects the
// design; one that loses the nesting prints other sums.
// Icarus Verilog 13.0 ends the formal argument list of INC at the right
// parenthesis inside the default, although a default may contain matched
// parentheses, so its INC has other text and the design does not compile.

`define INC(x = `INC(1)) ((x) + 1)
`define SUM(a, b) ((a) + (b))

module test_macro_self_use_in_actual_and_default;
  initial begin
    $display("in actuals: %0d %0d", `INC(`INC(`INC(5))),
             `SUM(`SUM(1, 20), `SUM(300, `SUM(4000, 50000))));
    $display("in the default: %0d, actual given: %0d", `INC(), `INC(10));
    $display("default inside an actual: %0d", `INC(`INC()));
  end
endmodule
