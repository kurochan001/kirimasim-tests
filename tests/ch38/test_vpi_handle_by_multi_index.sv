/*
:name: test_vpi_handle_by_multi_index
:description: vpi_handle_by_multi_index takes one index per unpacked dimension, leftmost first, optionally followed by a bit index, and returns NULL for indices that select nothing (IEEE 1800-2023 Section 38.20)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.20 38.15
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_handle_by_multi_index.c
:expected_stdout: @test_vpi_handle_by_multi_index.expected
*/
// IEEE 1800-2023 §38.20: vpi_handle_by_multi_index returns the subobject that
// an array of indices selects, in the order of the dimensions from the
// leftmost; a further index selects a bit of the element. Indices that do not
// form a legal select give NULL. mem has two unpacked dimensions [0:3][1:2] of
// 8-bit elements; {2, 1} selects mem[2][1] and {2, 1, 3} its bit 3, while
// {2, 1, 3, 0} would select a bit of a bit, which is no legal select. The
// values are read with vpi_get_value (38.15).

module test_vpi_handle_by_multi_index;
  logic [7:0] mem [0:3][1:2];

  initial begin
    mem[2][1] = 8'h5a;
    mem[3][2] = 8'h0f;
    $vt_lookup;
  end
endmodule
