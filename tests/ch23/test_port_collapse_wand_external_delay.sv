/*
:name: test_port_collapse_wand_external_delay
:description: A wand or triand port connected to an outer wand or triand net merges into the external net, whose delay the simulated net takes in all four combinations (IEEE 1800-2023 Section 23.3.3.7)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.7 28.16 6.6.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_port_collapse_wand_external_delay.expected
*/
// IEEE 1800-2023 §23.3.3.7: when a port connects nets, the simulated net
// takes the net type that Table 23-1 selects and "the delay specified for
// the dominating net". The wand/triand row of the table selects the
// external net when the internal net is a wand or triand and the external
// net is a wand or triand. Wand and triand are identical in syntax and
// functionality (§6.6.3), so the resolved value cannot show which of the
// two declarations the table selected; the net delay each declaration
// specifies (§28.16) can. The four cells below connect an internal wand
// or triand port to an external wand or triand net. The internal
// declaration has delay 3 and the external one delay 7; each cell has two
// instances, one driven by a continuous assignment inside the module and
// one by a separate driver module outside it. Choosing the external net,
// as the table says, gives the merged net delay 7 for both drivers.
// Keeping the internal net would give delay 3, adding the two delays would
// give 10 and no delay 0.
// The driver d goes to 1 at time 10 and to 0 at time 30, and each cell is
// sampled 2, 5 and 9 time units after each change. With one strong driver
// the wired-and net passes that driver, so delay 7 reads 0, 0, 1, 1, 1, 0
// (001110); delay 3 would read 011100, delay 10 000111 and no delay
// 111000. Icarus Verilog 13.0 does not support net delays, so this
// expected output follows the standard alone.

module pced_in_wand(w, d);
  parameter int D = 3;
  parameter bit DRIVE = 1'b1;
  inout w;
  input d;
  wand #(D) w;
  if (DRIVE) begin : g
    assign w = d;
  end
endmodule

module pced_in_triand(w, d);
  parameter int D = 3;
  parameter bit DRIVE = 1'b1;
  inout w;
  input d;
  triand #(D) w;
  if (DRIVE) begin : g
    assign w = d;
  end
endmodule

module pceda_drv(output w, input d);
  assign w = d;
endmodule

module test_port_collapse_wand_external_delay;
  logic d;

  // Suffix i: driver inside the port; suffix o: driver outside it.
  wand #7 n_ww_i, n_ww_o;
  triand #7 n_wt_i, n_wt_o;
  wand #7 n_tw_i, n_tw_o;
  triand #7 n_tt_i, n_tt_o;
  pceda_drv u_ww_d(n_ww_o, d);
  pceda_drv u_wt_d(n_wt_o, d);
  pceda_drv u_tw_d(n_tw_o, d);
  pceda_drv u_tt_d(n_tt_o, d);

  pced_in_wand #(.D(3)) u_ww_i(n_ww_i, d);
  pced_in_wand #(.D(3), .DRIVE(1'b0)) u_ww_o(n_ww_o, d);
  pced_in_wand #(.D(3)) u_wt_i(n_wt_i, d);
  pced_in_wand #(.D(3), .DRIVE(1'b0)) u_wt_o(n_wt_o, d);
  pced_in_triand #(.D(3)) u_tw_i(n_tw_i, d);
  pced_in_triand #(.D(3), .DRIVE(1'b0)) u_tw_o(n_tw_o, d);
  pced_in_triand #(.D(3)) u_tt_i(n_tt_i, d);
  pced_in_triand #(.D(3), .DRIVE(1'b0)) u_tt_o(n_tt_o, d);

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
    $display("wand inside, wand outside:     driven inside %b, outside %b",
             s_ww_i, s_ww_o);
    $display("wand inside, triand outside:   driven inside %b, outside %b",
             s_wt_i, s_wt_o);
    $display("triand inside, wand outside:   driven inside %b, outside %b",
             s_tw_i, s_tw_o);
    $display("triand inside, triand outside: driven inside %b, outside %b",
             s_tt_i, s_tt_o);
  end
endmodule
