/*
:name: test_directive_scope_across_include_until_superseded
:description: A compiler directive stays in effect from where it is processed, also after the end of the included file that holds it, until another directive supersedes it (IEEE 1800-2023 Section 22.2)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.2 22.4 22.5.1 22.7
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: directive_scope_helper.svh
:expected_stdout: @test_directive_scope_across_include_until_superseded.expected
*/
// IEEE 1800-2023 §22.2: compiler directives begin with the grave accent, and
// the scope of a directive extends from the point where it is processed,
// across the files processed in the compilation unit, until another
// directive supersedes it. Each of the three modules below measures its
// delay #1 in the time unit of the `timescale in effect where it is defined
// (§22.7) and records the value of the macro SCOPE_VALUE there (§22.5.1).
// scope_first follows `timescale 1ns / 1ns and SCOPE_VALUE 1. The file
// included next sets `timescale 1us / 1ns and redefines SCOPE_VALUE as 2, and
// both stay in effect after the include for scope_included. Then a
// `timescale 100ns / 1ns and a third definition supersede them for
// scope_superseded. The top module, in units of 1 ns, prints when each delay
// ends, in increasing order of time.

`timescale 1ns / 1ns
`define SCOPE_VALUE 1

module test_directive_scope_across_include_until_superseded;
  scope_first first();
  scope_included included();
  scope_superseded superseded();

  initial begin
    @(first.fired) $display("scope_first: delay of 1 ends at %0d ns, SCOPE_VALUE %0d",
                            $time, first.V);
    @(superseded.fired) $display("scope_superseded: delay of 1 ends at %0d ns, SCOPE_VALUE %0d",
                                 $time, superseded.V);
    @(included.fired) $display("scope_included: delay of 1 ends at %0d ns, SCOPE_VALUE %0d",
                               $time, included.V);
  end
endmodule

module scope_first;
  localparam int V = `SCOPE_VALUE;
  event fired;
  initial #1 -> fired;
endmodule

`include "directive_scope_helper.svh"

module scope_included;
  localparam int V = `SCOPE_VALUE;
  event fired;
  initial #1 -> fired;
endmodule

`timescale 100ns / 1ns
`undef SCOPE_VALUE
`define SCOPE_VALUE 3

module scope_superseded;
  localparam int V = `SCOPE_VALUE;
  event fired;
  initial #1 -> fired;
endmodule
