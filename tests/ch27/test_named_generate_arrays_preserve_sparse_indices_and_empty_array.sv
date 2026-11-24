/*
:name: test_named_generate_arrays_preserve_sparse_indices_and_empty_array
:description: VPI observes a named empty generate array and the actual sparse indices of another array
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 37.85
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_named_generate_arrays_preserve_sparse_indices_and_empty_array.expected
:vpi_c: @test_named_generate_arrays_preserve_sparse_indices_and_empty_array.c
*/
module test_named_generate_arrays_preserve_sparse_indices_and_empty_array;
  for (genvar i = 2; i < 10; i += 3) begin : sparse
    wire sampled = i[0];
  end
  for (genvar i = 1; i < 1; i++) begin : empty
    wire sampled = 1'b1;
  end

  initial #1 $finish;
endmodule
