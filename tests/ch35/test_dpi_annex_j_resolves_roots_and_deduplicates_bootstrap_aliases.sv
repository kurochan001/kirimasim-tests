/*
:name: test_dpi_annex_j_resolves_roots_and_deduplicates_bootstrap_aliases
:description: Relative roots, absolute paths, and hard-linked aliases select the intended DPI objects
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.4 J.2 J.3 J.4 J.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: annex j roots=84,63,42,21
:dpi_c: @dpi_annex_j_objects.c
*/
module test_dpi_annex_j_resolves_roots_and_deduplicates_bootstrap_aliases;
  import "DPI-C" function int annex_j_a(input int value);
  import "DPI-C" function int annex_j_b(input int value);
  import "DPI-C" function int annex_j_c(input int value);
  import "DPI-C" function int annex_j_d(input int value);

  initial begin
    $display("annex j roots=%0d,%0d,%0d,%0d", annex_j_d(40), annex_j_c(30),
             annex_j_b(20), annex_j_a(10));
  end
endmodule
