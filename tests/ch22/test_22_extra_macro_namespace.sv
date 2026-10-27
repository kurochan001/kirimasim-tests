/*
:name: test_22_extra_macro_namespace
:description: Ordinary identifiers may have the spelling of a compiler directive keyword, a macro name may also be an ordinary identifier, and the latest definition of a macro governs the uses after it (IEEE 1800-2023 Section 22.5.1)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_22_extra_macro_namespace.expected
*/
// IEEE 1800-2023 §22.5.1: compiler directive keywords are not part of the
// normal set of keywords, so identifiers in the source may be spelled like
// them; the variables define, resetall, timescale and celldefine below show
// that. A text macro name can reuse a name used as an ordinary identifier:
// VALUE is both a variable and a macro, and `VALUE and VALUE are different
// things. Redefinition of a macro is allowed and the latest definition read by
// the compiler prevails, so first keeps the value from the first definition
// while the later use sees the second one.

`define VALUE 11

module test_22_extra_macro_namespace;
  int define = 1;
  int resetall = 2;
  int timescale = 3;
  int celldefine = 4;
  int VALUE = 5;
  int first = `VALUE;

`define VALUE 22

  initial begin
    #1 $display("directive names: %0d %0d %0d %0d", define, resetall, timescale, celldefine);
    #1 $display("first=%0d second=%0d identifier=%0d", first, `VALUE, VALUE);
  end
endmodule
