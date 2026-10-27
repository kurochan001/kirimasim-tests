/*
:name: test_port_collapse_wor_external_delay
:description: A wor or trior port connected to an outer wor or trior net merges into the external net, whose delay the simulated net takes in all four combinations (IEEE 1800-2023 Section 23.3.3.7)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.7 28.16 6.6.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_port_collapse_wor_external_delay.expected
*/
// IEEE 1800-2023 §23.3.3.7: when a port connects nets, the simulated net
// takes the net type that Table 23-1 selects and "the delay specified for
// the dominating net". The wor/trior row of the table selects the
// external net when the internal net is a wor or trior and the external
// net is a wor or trior. Wor and trior are identical in syntax and
// functionality (§6.6.3), so the resolved value cannot show which of the
// two declarations the table selected; the net delay each declaration
// specifies (§28.16) can.
// The four cells below connect an internal wor or trior port to an
// external wor or trior net. The internal declaration has delay 3 and the
// external one delay 7; each cell has two instances, one driven by a
// continuous assignment inside the module and one by a separate driver
// module outside it. Choosing the external net, as the table says, gives
// the merged net delay 7 for both drivers. Keeping the internal net would
// give delay 3, adding the two delays would give 10 and no delay would
// give 0.
// The driver d goes to 1 at time 10 and to 0 at time 30, and each cell is
// sampled 2, 5 and 9 time units after each change. With one strong driver
// the wired-or net passes that driver, so delay 7 reads 0, 0, 1, 1, 1, 0
// (001110); delay 3 would read 011100, delay 10 000111 and no delay
// 111000. Icarus Verilog 13.0 does not support net delays, so this
// expected output follows the standard alone.

module pced_in_wor(w, d);
  parameter int D = 3;
  parameter bit DRIVE = 1'b1;
  inout w;
  input d;
  wor #(D) w;
  if (DRIVE) begin : g
    assign w = d;
  end
endmodule

module pced_in_trior(w, d);
  parameter int D = 3;
  parameter bit DRIVE = 1'b1;
  inout w;
  input d;
  trior #(D) w;
  if (DRIVE) begin : g
    assign w = d;
  end
endmodule

module pcedo_drv(output w, input d);
  assign w = d;
endmodule

module test_port_collapse_wor_external_delay;
  logic d;

  // Suffix i: driver inside the port; suffix o: driver outside it.
  wor #7 n_ww_i, n_ww_o;
  trior #7 n_wt_i, n_wt_o;
  wor #7 n_tw_i, n_tw_o;
  trior #7 n_tt_i, n_tt_o;
  pcedo_drv u_ww_d(n_ww_o, d);
  pcedo_drv u_wt_d(n_wt_o, d);
  pcedo_drv u_tw_d(n_tw_o, d);
  pcedo_drv u_tt_d(n_tt_o, d);

  pced_in_wor #(.D(3)) u_ww_i(n_ww_i, d);
  pced_in_wor #(.D(3), .DRIVE(1'b0)) u_ww_o(n_ww_o, d);
  pced_in_wor #(.D(3)) u_wt_i(n_wt_i, d);
  pced_in_wor #(.D(3), .DRIVE(1'b0)) u_wt_o(n_wt_o, d);
  pced_in_trior #(.D(3)) u_tw_i(n_tw_i, d);
  pced_in_trior #(.D(3), .DRIVE(1'b0)) u_tw_o(n_tw_o, d);
  pced_in_trior #(.D(3)) u_tt_i(n_tt_i, d);
  pced_in_trior #(.D(3), .DRIVE(1'b0)) u_tt_o(n_tt_o, d);

  logic [0:5] s_ww_i, s_ww_o, s_wt_i, s_wt_o;
  logic [0:5] s_tw_i, s_tw_o, s_tt_i, s_tt_o;

  task automatic sample(int k);
    s_ww_i[k] = n_ww_i;
    s_ww_o[k] = n_ww_o;
    s_wt_i[k] = n_wt_i;
    s_wt_o[k] = n_wt_o;
    s_tw_i[k] = n_tw_i;
    s_tw_o[k] = n_tw_o;
    s_tt_i[k] = n_tt_i;
    s_tt_o[k] = n_tt_o;
  endtask

  initial begin
    d = 1'b0;
    #10 d = 1'b1;
    #2 sample(0);
    #3 sample(1);
    #4 sample(2);
    #11 d = 1'b0;
    #2 sample(3);
    #3 sample(4);
    #4 sample(5);
    $display("wor inside, wor outside:       driven inside %b, outside %b",
             s_ww_i, s_ww_o);
    $display("wor inside, trior outside:     driven inside %b, outside %b",
             s_wt_i, s_wt_o);
    $display("trior inside, wor outside:     driven inside %b, outside %b",
             s_tw_i, s_tw_o);
    $display("trior inside, trior outside:   driven inside %b, outside %b",
             s_tt_i, s_tt_o);
  end
endmodule
