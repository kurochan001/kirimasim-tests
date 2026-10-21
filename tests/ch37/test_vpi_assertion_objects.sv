/*
:name: test_vpi_assertion_objects
:description: the concurrent assertions of a module are found by iterating vpiAssertion over the module and over NULL and by name; each gives its instance, file and line, the clock it is evaluated on, whether a written or a procedural clock is inferred, a cover whether it covers a sequence, an assert its pass and fail statements, a property spec with its disable condition, and a restrict no statement; a named block gives its procedural concurrent assertion (IEEE 1800-2023 Sections 37.49 and 37.50)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.49 37.50 37.52 37.12 39.3.1 39.3.2 16.14.6 16.14.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_objects.c
:expected_stdout: @test_vpi_assertion_objects.expected
*/
// IEEE 1800-2023 §37.49, §39.3.1: vpi_iterate(vpiAssertion) over an instance,
// or over NULL for the whole design, gives its assertions, and a named
// assertion can be found by name; an assertion leads to its instance and has
// the location properties vpiFile, vpiStartLine and vpiEndLine (§39.3.2),
// here all on the one line of a_expl. §37.50: vpiClockingEvent is the clock
// on which the assertion is evaluated, whether written or not (detail 1):
// negedge clk for a_expl and posedge clk, of the default clocking, for the
// others of the module. vpiIsClockInferred is FALSE for an assertion with its
// own clock, and TRUE for a_proc, whose clock posedge clk2 is inferred from
// its always procedure (§16.14.6); a_proc is reached from its named block,
// which iterates its concurrent assertions (37.12). vpiIsCoverSequence tells
// cover sequence from cover property. vpiStmt and vpiElseStmt give the pass
// and fail statements of an assert; a restrict property has no action
// statement (detail 2, §16.14.4). vpiProperty of a_inf is a property spec,
// whose vpiDisableCondition is rst (§37.52). The application checks that both
// iterations contain the six assertions of the module, and prints them in a
// fixed order.

`timescale 1ns/1ns

module test_vpi_assertion_objects;
  logic clk = 0, clk2 = 0, a = 1, b = 1, rst = 0;
  int passes = 0, fails = 0;

  default clocking dcb @(posedge clk);
  endclocking

  property p_ab;
    a |-> b;
  endproperty

  a_expl: assert property (@(negedge clk) a) passes++; else fails++;
  a_inf: assert property (disable iff (rst) a |-> b);
  c_prop: cover property (@(posedge clk) a);
  c_seq: cover sequence (a ##1 b);
  m_inst: assume property (p_ab);
  r_prop: restrict property (@(posedge clk) b);

  always @(posedge clk2) begin : blk
    a_proc: assert property (a |-> b);
  end

  initial #1 $vt_assertions;
endmodule
