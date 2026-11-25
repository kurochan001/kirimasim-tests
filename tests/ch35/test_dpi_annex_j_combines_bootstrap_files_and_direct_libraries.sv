/*
:name: test_dpi_annex_j_combines_bootstrap_files_and_direct_libraries
:description: Ordered bootstrap entries and direct selections provide four different DPI symbols
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.4 J.2 J.3 J.4 J.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: annex j bootstrap=14,26,38,50
:dpi_c: @dpi_annex_j_objects.c
*/
module test_dpi_annex_j_combines_bootstrap_files_and_direct_libraries;
  import "DPI-C" function int annex_j_a(input int value);
  import "DPI-C" function int annex_j_b(input int value);
  import "DPI-C" function int annex_j_c(input int value);
  import "DPI-C" function int annex_j_d(input int value);

  initial begin
    $display("annex j bootstrap=%0d,%0d,%0d,%0d", annex_j_a(3), annex_j_b(4),
             annex_j_c(5), annex_j_d(6));
  end
endmodule
