/*
:name: test_specify_edge_path_full_polarity_data_source
:description: Edge-sensitive paths may use a parallel or a full connection, a polarity operator before the connection or before the colon, and a data source expression or none; the polarity does not change which delay a destination transition takes (IEEE 1800-2023 Section 30.4.3)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_edge_path_full_polarity_data_source.expected
*/
// IEEE 1800-2023 §30.4.3: an edge-sensitive path connects its source with =>
// (parallel) or *> (full) to its destinations, optionally with a polarity
// operator and optionally with a data source expression after a colon. The
// data source expression only describes the flow of data, and the polarity
// operator has no effect on simulation results. A two-value delay gives the
// rise and the fall delay of the destination (30.5.1).
//
// Every cell loads d into a register at the rising edge of clk. The cells
// pa, ma and mc buffer it to q, with (20, 50) on these paths:
//   pa: (posedge clk => (q +: d))   positive polarity, data source d
//   ma: (posedge clk => (q -: d))   negative polarity, data source d
//   mc: (posedge clk -=> q)         negative polarity, no data source
// The cell fu buffers it to qa and inverts it to qb, and the cell fv drives
// the 2-bit qv with the register and its inverse, with (30, 60) on
//   fu: (posedge clk *> (qa, qb -: ~d))   full, two outputs, data source ~d
//   fv: (posedge clk +*> qv)              full, vector output, no data source
// d rises at 90 and clk at 100: q of pa, ma and mc rises at 120 by the rise
// delay whatever the polarity; qa and qv[1] rise at 130, qb and qv[0] fall at
// 160. clk falls at 150 and changes nothing. d falls at 190 and clk rises at
// 200: q falls at 250, qb and qv[0] rise at 230, qa and qv[1] fall at 260.
// Every change is at a multiple of 10. The outputs are sampled 5 after each
// multiple of 10 from 105 on, and a sample that differs from the one before
// prints the time of the change, 5 earlier, and the outputs.
//
// Icarus Verilog 13.0 rejects the edge-sensitive paths without a data source
// (mc and fv) as syntax errors. With data sources added to them it compiles
// the test but says that it uses the delay of the LSB for every bit of a
// multi-bit destination, so qv[1] does not rise at 130. The 5.054 release
// of Verilator ignores module path delays.

`timescale 1ns/1ns

module test_specify_edge_path_full_polarity_data_source_pa (input clk, input d, output q);
  reg qi = 0;
  always @(posedge clk) qi <= d;
  buf g (q, qi);
  specify
    (posedge clk => (q +: d)) = (20, 50);
  endspecify
endmodule

module test_specify_edge_path_full_polarity_data_source_ma (input clk, input d, output q);
  reg qi = 0;
  always @(posedge clk) qi <= d;
  buf g (q, qi);
  specify
    (posedge clk => (q -: d)) = (20, 50);
  endspecify
endmodule

module test_specify_edge_path_full_polarity_data_source_mc (input clk, input d, output q);
  reg qi = 0;
  always @(posedge clk) qi <= d;
  buf g (q, qi);
  specify
    (posedge clk -=> q) = (20, 50);
  endspecify
endmodule

module test_specify_edge_path_full_polarity_data_source_fu
  (input clk, input d, output qa, output qb);
  reg qi = 0;
  always @(posedge clk) qi <= d;
  buf ga (qa, qi);
  not gb (qb, qi);
  specify
    (posedge clk *> (qa, qb -: ~d)) = (30, 60);
  endspecify
endmodule

module test_specify_edge_path_full_polarity_data_source_fv
  (input clk, input d, output [1:0] qv);
  reg qi = 0;
  always @(posedge clk) qi <= d;
  buf g1 (qv[1], qi);
  not g0 (qv[0], qi);
  specify
    (posedge clk +*> qv) = (30, 60);
  endspecify
endmodule

module test_specify_edge_path_full_polarity_data_source;
  reg clk = 0, d = 0;
  wire qpa, qma, qmc, qa, qb;
  wire [1:0] qv;
  logic [6:0] prev;

  test_specify_edge_path_full_polarity_data_source_pa upa (clk, d, qpa);
  test_specify_edge_path_full_polarity_data_source_ma uma (clk, d, qma);
  test_specify_edge_path_full_polarity_data_source_mc umc (clk, d, qmc);
  test_specify_edge_path_full_polarity_data_source_fu ufu (clk, d, qa, qb);
  test_specify_edge_path_full_polarity_data_source_fv ufv (clk, d, qv);

  initial begin
    #90 d = 1;
    #10 clk = 1;      // 100
    #50 clk = 0;      // 150
    #40 d = 0;
    #10 clk = 1;      // 200
  end

  initial begin
    #95 prev = {qpa, qma, qmc, qa, qb, qv};
    repeat (25) begin
      #10 if ({qpa, qma, qmc, qa, qb, qv} != prev)
        $display("%0d: pa=%b ma=%b mc=%b qa=%b qb=%b qv=%b", $time - 5, qpa, qma, qmc, qa, qb,
                 qv);
      prev = {qpa, qma, qmc, qa, qb, qv};
    end
    $finish;
  end
endmodule
