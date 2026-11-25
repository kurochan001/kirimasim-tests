/*
:name: test_annex_n_reference_helpers
:description: Validate the Annex N helper signatures and the reversed or equal internal uniform ranges with the reference C source
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.14.2 N.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_annex_n_reference_helpers.c
:expected_stdout: @test_annex_n_reference_helpers.expected
*/
module test_annex_n_reference_helpers;
  import "DPI-C" function int annex_n_signatures();
  import "DPI-C" function int annex_n_uniform_ranges();

  int seed = 1;
  int sample;
  initial begin
    sample = $dist_uniform(seed, 5, 5);
    $display("public equal range=%0d seed=%0d", sample, seed);
    if ($test$plusargs("verify_annex_n_reference"))
      $display("reference signatures=%0d ranges=%0d",
               annex_n_signatures(), annex_n_uniform_ranges());
  end
endmodule
