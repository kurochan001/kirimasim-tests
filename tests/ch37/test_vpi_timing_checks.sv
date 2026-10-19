/*
:name: test_vpi_timing_checks
:description: a module gives its timing checks with their type, reference and data terms, the edges and terminals of those terms, the notifier and the limit (IEEE 1800-2023 Section 37.40)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.40 38.10 31.2 31.3.1 31.3.2 31.3.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_timing_checks.c
:expected_stdout: @test_vpi_timing_checks.expected
*/
// IEEE 1800-2023 §37.40: vpi_iterate(vpiTchk, module) gives the timing checks
// of the module; vpiTchkType tells which check it is; vpiTchkRefTerm denotes
// the reference event and vpiTchkDataTerm the data event (detail 1), each a
// tchk term with vpiEdge and the terminal as its expression; vpiTchkNotifier
// is the notifier; vpi_get_delays with as many delays as the check has limits
// returns the limit (§38.10). For $setup (§31.3.1) the reference event is the
// second argument; for $hold (§31.3.2) and $recovery (§31.3.5), the first.
// The application prints one line per check, sorted.

module checks(input clk, d, rst);
  reg n = 0;
  specify
    $setup(d, posedge clk, 3, n);
    $hold(posedge clk, d, 2, n);
    $recovery(negedge rst, posedge clk, 4);
  endspecify
endmodule

module test_vpi_timing_checks;
  logic clk = 0, d = 0, rst = 1;

  checks u(clk, d, rst);

  initial #1 $vt_checks;
endmodule
