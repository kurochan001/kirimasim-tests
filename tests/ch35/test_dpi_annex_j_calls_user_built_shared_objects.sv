/*
:name: test_dpi_annex_j_calls_user_built_shared_objects
:description: A design calls functions from four user-built shared objects
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.4 J.2 J.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: annex j all=11,22,33,44
:dpi_c: @dpi_annex_j_objects.c
*/
module test_dpi_annex_j_calls_user_built_shared_objects;
  import "DPI-C" function int annex_j_a(input int value);
  import "DPI-C" function int annex_j_b(input int value);
  import "DPI-C" function int annex_j_c(input int value);
  import "DPI-C" function int annex_j_d(input int value);

  initial begin
    $display("annex j all=%0d,%0d,%0d,%0d", annex_j_a(0), annex_j_b(0),
             annex_j_c(0), annex_j_d(0));
  end
endmodule
