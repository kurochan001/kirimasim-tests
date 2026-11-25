/*
:name: test_dpi_annex_j_keeps_multiple_prebuilt_objects_available
:description: A design calls earlier and later shared objects after loading them in another order
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.4 J.2 J.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: annex j reordered=45,12,34,23,13
:dpi_c: @dpi_annex_j_objects.c
*/
module test_dpi_annex_j_keeps_multiple_prebuilt_objects_available;
  import "DPI-C" function int annex_j_a(input int value);
  import "DPI-C" function int annex_j_b(input int value);
  import "DPI-C" function int annex_j_c(input int value);
  import "DPI-C" function int annex_j_d(input int value);

  initial begin
    $display("annex j reordered=%0d,%0d,%0d,%0d,%0d", annex_j_d(1), annex_j_a(1),
             annex_j_c(1), annex_j_b(1), annex_j_a(2));
  end
endmodule
