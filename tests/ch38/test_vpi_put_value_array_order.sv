/*
:name: test_vpi_put_value_array_order
:description: vpi_put_value_array on two-dimensional arrays fills the elements from the start index with the rightmost index varying fastest and the values of each range from its left bound to its right bound, also for descending ranges (IEEE 1800-2023 Section 38.35)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.35
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_put_value_array_order.c
:expected_stdout: @test_vpi_put_value_array_order.expected
*/
// IEEE 1800-2023 §38.35: vpi_put_value_array writes num elements of a static
// unpacked array, starting at the element whose indices index_p gives, one per
// unpacked dimension, leftmost first. The rightmost index varies fastest, then
// the next one to the left, and the values of each range are taken from its
// left bound to its right bound, whether it ascends or descends. At the start
// of the simulation the application writes 4 values into g from g[1][1], so
// after g[1][2] comes g[0][0], and 3 values into h from h[0][2], so after
// h[0][1] comes h[1][3]; the design prints the arrays at time 1. Verilator
// 5.052 writes them from another element and in another order (44 33 22 / 11
// 0 0 for g, 3 2 1 / 0 0 0 for h).

module test_vpi_put_value_array_order;
  int g [1:0][0:2];
  int h [0:1][3:1];

  initial begin
    #1;
    $display("g[1][0:2]: %0d %0d %0d, g[0][0:2]: %0d %0d %0d",
             g[1][0], g[1][1], g[1][2], g[0][0], g[0][1], g[0][2]);
    $display("h[0][3:1]: %0d %0d %0d, h[1][3:1]: %0d %0d %0d",
             h[0][3], h[0][2], h[0][1], h[1][3], h[1][2], h[1][1]);
  end
endmodule
