/*
:name: test_timing_stability_windows_and_endpoints
:description: The stability-window checks $setup, $hold, $removal and $recovery define a window from one event and the limit and report a transition of the other event inside it, each with its own excluded endpoints, so a transition on an excluded endpoint passes and one inside is reported (IEEE 1800-2023 Section 31.3)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.3 31.3.1 31.3.2 31.3.4 31.3.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_stability_windows_and_endpoints.expected
*/
// IEEE 1800-2023 §31.3: these checks define a time window with respect to the
// reference signal and the limit, check the time of the data transition
// against it, and report a violation if it falls within the window. $setup
// and $removal stamp the data event and check at the reference event; the
// window is the limit before the reference, both ends excluded (31.3.1,
// 31.3.4). $hold and $recovery stamp the reference event and check at the
// data event; the window starts at the reference and its end is excluded
// (31.3.2, 31.3.5). Each check has its own signals and notifier. Up to 16
// each sees one pair of transitions exactly one limit apart, on the excluded
// end of its window; from 20 each sees a pair inside its window.
// Neither Icarus Verilog 13.0 nor the 5.052 release of Verilator performs
// timing checks; the expected output is the one the cited clauses give.

`timescale 1ns/1ns

module tsw_cell(input wire cs, input wire ds, input wire ch, input wire dh,
                input wire cm, input wire dm, input wire cr, input wire dr);
  reg ns = 1'b0, nh = 1'b0, nm = 1'b0, nr = 1'b0;
  specify
    $setup(ds, posedge cs, 4, ns);
    $hold(posedge ch, dh, 3, nh);
    $removal(posedge cm, dm, 3, nm);
    $recovery(posedge cr, dr, 4, nr);
  endspecify
endmodule

module test_timing_stability_windows_and_endpoints;
  logic cs = 1'b0, ds = 1'b0, ch = 1'b0, dh = 1'b0;
  logic cm = 1'b0, dm = 1'b0, cr = 1'b0, dr = 1'b0;
  tsw_cell u (.cs(cs), .ds(ds), .ch(ch), .dh(dh), .cm(cm), .dm(dm), .cr(cr), .dr(dr));
  // $setup, limit 4: data at 10 and 21, reference at 14 and 24.
  initial begin
    #10 ds = 1'b1;
    #4 cs = 1'b1;
    #3 cs = 1'b0;
    #4 ds = 1'b0;
    #3 cs = 1'b1;
  end
  // $hold, limit 3: reference at 10 and 20, data at 13 and 22.
  initial begin
    #10 ch = 1'b1;
    #3 dh = 1'b1;
    #4 ch = 1'b0;
    #3 ch = 1'b1;
    #2 dh = 1'b0;
  end
  // $removal, limit 3: data at 10 and 21, reference at 13 and 23.
  initial begin
    #10 dm = 1'b1;
    #3 cm = 1'b1;
    #4 cm = 1'b0;
    #4 dm = 1'b0;
    #2 cm = 1'b1;
  end
  // $recovery, limit 4: reference at 10 and 20, data at 14 and 22.
  initial begin
    #10 cr = 1'b1;
    #4 dr = 1'b1;
    #3 cr = 1'b0;
    #3 cr = 1'b1;
    #2 dr = 1'b0;
  end
  initial begin
    #16 $display("t=16 setup=%b hold=%b removal=%b recovery=%b", u.ns, u.nh, u.nm, u.nr);
    #10 $display("t=26 setup=%b hold=%b removal=%b recovery=%b", u.ns, u.nh, u.nm, u.nr);
  end
endmodule
