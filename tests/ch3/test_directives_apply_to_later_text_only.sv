/*
:name: test_directives_apply_to_later_text_only
:description: A compiler directive applies to the source text after it, across module boundaries, and never to the text before it; a later definition of a text macro replaces the earlier one for the rest of the input (IEEE 1800-2023 Section 3.12.1)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.12.1 3.13 22.5.1 22.7
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_directives_apply_to_later_text_only.expected
*/
// IEEE 1800-2023 §3.12.1: within a compilation unit, a compiler directive
// applies to all the source text after it. §3.13 d): text macro names are
// global to the compilation unit, defined in the order in which they appear,
// and a later definition of a name overrides the earlier one for the rest of
// the input. §22.5.1: `define; §22.7: `timescale.
// The module early is read while the macro VALUE is 1, LATE_FLAG is not
// defined and `timescale 1ns/1ns holds; the macro INNER is defined at the end
// of its body. The top module follows. Then VALUE is defined again as 2,
// without `undef, LATE_FLAG is defined and `timescale 10ns/1ns comes. The
// module late sees VALUE as 2, LATE_FLAG and INNER as defined, and its #1
// lasts 10ns. The module early keeps 1, an undefined LATE_FLAG and its 1ns
// unit: its flag is set at 1ns, that of late only at 10ns, so the check of
// the top module, also in 1ns units, sees early_flag=1 and late_flag=0 at
// 2ns and both at 12ns.

`timescale 1ns/1ns
`define VALUE 1

module directive_early(output int value, output int flag_seen, output bit done);
  initial begin
    value = `VALUE;
`ifdef LATE_FLAG
    flag_seen = 1;
`else
    flag_seen = 0;
`endif
    #1 done = 1;
  end
`define INNER 5
endmodule

module test_directives_apply_to_later_text_only;
  int ev, ef, lv, lf, li;
  bit ed, ld;

  directive_early e(.value(ev), .flag_seen(ef), .done(ed));
  directive_late l(.value(lv), .flag_seen(lf), .inner(li), .done(ld));

  initial begin
    #2 $display("early: VALUE=%0d LATE_FLAG=%0d", ev, ef);
    $display("late: VALUE=%0d LATE_FLAG=%0d INNER=%0d", lv, lf, li);
    $display("at 2ns: early_flag=%0d late_flag=%0d", ed, ld);
    #10 $display("at 12ns: early_flag=%0d late_flag=%0d", ed, ld);
  end
endmodule

`define VALUE 2
`define LATE_FLAG
`timescale 10ns/1ns

module directive_late(output int value, output int flag_seen, output int inner,
                      output bit done);
  initial begin
    value = `VALUE;
`ifdef LATE_FLAG
    flag_seen = 1;
`else
    flag_seen = 0;
`endif
    inner = `INNER;
    #1 done = 1;
  end
endmodule
