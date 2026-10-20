/*
:name: test_dpi_sized_unpacked_array
:description: A sized unpacked array argument is passed to C as an array whose element 0 is the element with the lowest SystemVerilog index, for ascending and descending ranges, and an output array is copied back (IEEE 1800-2023 Section 35.5.6)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6 H.7.6 H.8.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_sized_unpacked_array.c
:expected_stdout: @test_dpi_sized_unpacked_array.expected
*/
// IEEE 1800-2023 §35.5.6: unpacked arrays of permitted types may be formal
// arguments. H.7.6 c): in C the element with the smallest SystemVerilog index
// has index 0, whatever the direction of the range, so for up[1:4] the C
// element 0 is up[1], and for down[3:0] it is down[0]. dpi_weigh multiplies
// each element by its C index plus 1; an input array is passed by reference
// (H.8.7). dpi_ramp fills an output array, which is copied back.

module test_dpi_sized_unpacked_array;
  import "DPI-C" function int dpi_weigh(input int a[1:4]);
  import "DPI-C" function int dpi_weigh_down(input int a[3:0]);
  import "DPI-C" function void dpi_ramp(output int r[1:4]);

  int up[1:4] = '{10, 20, 30, 40};
  int down[3:0] = '{10, 20, 30, 40};
  int r[1:4];

  initial begin
    $display("up[1:4]: %0d", dpi_weigh(up));
    $display("down[3:0]: %0d", dpi_weigh_down(down));
    dpi_ramp(r);
    $display("ramp: r[1]=%0d r[2]=%0d r[3]=%0d r[4]=%0d", r[1], r[2], r[3], r[4]);
  end
endmodule
