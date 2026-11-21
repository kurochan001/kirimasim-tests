// Copyright (c) 2026 The kirimasim Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Original design. Independent oracle: bench/reference_holdout.py.
// spec_check: ai; IEEE 1800-2023 25 (interfaces, modports), 9.4.2 and 10.4.2 (edges, NBAs).
// bench-n: 1000000
// bench-expect: intf_modport n=1000000 checksum=dc06be40 accepted=1000000 transfers=1000000 parity=41d71d40
// bench-expect-small: intf_modport n=1 checksum=3c88596c accepted=1 transfers=1 parity=3c88596c
`timescale 1ns/1ns
// A source, a sink and a monitor connected through modports of one
// interface. A word moves on a clock edge where valid and ready are both 1.
interface holdout_link(input logic clk);
  logic valid = 0, ready = 0, done = 0;
  logic [31:0] data = 0;
  modport source(input clk, ready, output valid, data, done);
  modport sink(input clk, valid, data, output ready);
  modport probe(input clk, valid, ready, data);
endinterface
module holdout_source(holdout_link.source link);
  int n, offered = 0;
  logic [31:0] seed = 1;
  initial if (!$value$plusargs("n=%d", n)) n = 1000000;
  always @(posedge link.clk)
    if (!link.valid || link.ready) begin
      if (offered < n) begin
        seed = seed * 32'd1664525 + 32'd1013904223;
        link.data <= seed;
        link.valid <= 1;
        offered <= offered + 1;
      end else begin
        link.valid <= 0;
        link.done <= 1;
      end
    end
endmodule
module holdout_sink(holdout_link.sink link);
  logic [31:0] checksum = 0;
  int accepted = 0, cycle = 0;
  always @(posedge link.clk) begin
    if (link.valid && link.ready) begin
      checksum <= (checksum * 33) ^ link.data;
      accepted <= accepted + 1;
    end
    link.ready <= cycle % 3 != 0;
    cycle <= cycle + 1;
  end
endmodule
module holdout_probe(holdout_link.probe link);
  logic [31:0] parity = 0;
  int transfers = 0;
  always @(posedge link.clk)
    if (link.valid && link.ready) begin
      parity <= parity ^ link.data;
      transfers <= transfers + 1;
    end
endmodule
module intf_modport;
  logic clk = 0;
  holdout_link link(clk);
  holdout_source source(link);
  holdout_sink sink(link);
  holdout_probe probe(link);
  always #1 clk = ~clk;
  initial begin
    wait (link.done);
    repeat (2) @(posedge clk);
    $display("intf_modport n=%0d checksum=%h accepted=%0d transfers=%0d parity=%h",
             source.n, sink.checksum, sink.accepted, probe.transfers, probe.parity);
    $finish;
  end
endmodule
