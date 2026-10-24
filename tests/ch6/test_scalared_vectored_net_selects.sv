/*
:name: test_scalared_vectored_net_selects
:description: The advisory keywords scalared and vectored are accepted in vector net declarations; a scalared net can be driven and read through bit-selects and part-selects, and a vectored net works as a whole (IEEE 1800-2023 Section 6.9.2)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.9.2 6.7 10.3 6.6.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_scalared_vectored_net_selects.expected
*/
// IEEE 1800-2023 §6.9.2: vectored and scalared are optional advisory keywords
// of a vector net declaration (6.7). On a scalared net, bit-selects and
// part-selects are permitted; on a vectored one they may be restricted, so it
// is used here only as a whole. sbus is driven by three continuous
// assignments (10.3) to a part-select, a bit-select and another part-select,
// and read whole, by a bit-select and by a part-select. src is 8'h5a, so sbus
// is {4'b1010, 1'b1, 3'b101} = 8'hAD. The scalared tri1 net pbus has only its
// bit 1 driven, to 0; its other bits have the pull 1 of tri1 (6.6.5).

module test_scalared_vectored_net_selects;
  logic [7:0] src = 8'h5a;
  wire scalared [7:0] sbus;
  wire vectored [7:0] vbus;
  tri1 scalared [3:0] pbus;

  assign sbus[7:4] = src[3:0];
  assign sbus[3] = 1'b1;
  assign sbus[2:0] = src[6:4];
  assign vbus = src;
  assign pbus[1] = 1'b0;

  initial #1 $display("sbus=%h sbus[5]=%b sbus[6:4]=%b vbus=%h pbus=%b pbus[1:0]=%b", sbus,
                      sbus[5], sbus[6:4], vbus, pbus, pbus[1:0]);
endmodule
