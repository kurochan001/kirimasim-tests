/*
:name: test_net_four_state_data_types
:description: A net without a data type, or with only a range, is logic and holds x and z; a net can also be declared with a 4-state data type such as logic, integer, a typedef of logic or a packed structure, or as a fixed-size unpacked array of such nets (IEEE 1800-2023 Section 6.7.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.7.1 6.11.1 6.11.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_net_four_state_data_types.expected
*/
// IEEE 1800-2023 §6.7.1: if a net declaration gives no data type, or only a
// range or signing, the data type is logic. A valid data type for a net is a
// 4-state integral type, packed structures included (6.11.1), or a fixed-size
// unpacked array of valid net types; so every bit of a net is a 4-state bit
// (6.11.2) and can be 0, 1, x or z.
// Each net is driven with a value that has x and z bits, which it keeps:
// w1 has no data type, wv only a range, wl the type logic, wi the type
// integer, wn a typedef of logic, wsp a packed structure, and wa is an
// unpacked array of two logic nets.

module test_net_four_state_data_types;
  typedef logic [3:0] nib_t;
  typedef struct packed { logic hi; logic [2:0] lo; } pair_t;

  wire w1;
  wire [3:0] wv;
  wire logic [7:0] wl;
  wire integer wi;
  wire nib_t wn;
  wire pair_t wsp;
  wire logic [1:0] wa [0:1];

  assign w1 = 1'bx;
  assign wv = 4'bx0z1;
  assign wl = 8'b10xz_zx01;
  assign wi = 32'hxxxx_zz05;
  assign wn = 4'bz1x0;
  assign wsp = 4'bx01z;
  assign wa[0] = 2'bxz;
  assign wa[1] = 2'bz1;

  initial begin
    #1 $display("no data type: w1=%b bits %0d, range only: wv=%b", w1, $bits(w1), wv);
    $display("logic: wl=%b integer: wi=%h bits %0d", wl, wi, $bits(wi));
    $display("typedef: wn=%b packed struct: hi=%b lo=%b", wn, wsp.hi, wsp.lo);
    $display("unpacked array: wa[0]=%b wa[1]=%b", wa[0], wa[1]);
  end
endmodule
