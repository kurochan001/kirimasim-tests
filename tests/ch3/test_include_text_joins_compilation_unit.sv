/*
:name: test_include_text_joins_compilation_unit
:description: The text of a file included with `include outside any module becomes part of the compilation unit of the including file, so its declarations are in that compilation-unit scope (IEEE 1800-2023 Section 3.12.1)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.12.1 22.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: include_text_joins_unit_items.svh
:expected_stdout: @test_include_text_joins_compilation_unit.expected
*/
// IEEE 1800-2023 §3.12.1: the contents of a file included with `include
// (§22.4) become part of the compilation unit of the file that includes it.
// The included file declares, outside any other scope, a variable, an enum
// type and a function. This file includes it before its own declarations:
// a compilation-unit variable of this file is initialized from the included
// variable, and the module reads the variable through $unit::, declares a
// variable of the included type and calls the included function. All of
// this needs the included declarations in the compilation-unit scope of this
// file.

`include "include_text_joins_unit_items.svh"

int after_include = inc_count + 1;

module test_include_text_joins_compilation_unit;
  inc_color_t c = INC_BLUE;

  initial begin
    $display("unit: inc_count=%0d after_include=%0d", $unit::inc_count, $unit::after_include);
    $display("type: %s=%0d function: %0d", c.name(), c, inc_double(21));
  end
endmodule
