// Copyright (c) 2026 The kirimasim Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Original design. Independent oracle: bench/reference_holdout.py.
// spec_check: ai; IEEE 1800-2023 8 (classes, inheritance, virtual methods) and 7.4 (arrays of handles).
// bench-n: 800000
// bench-expect: class_pool n=800000 checksum=47210840 consumed=800000 reads=400000
// bench-expect-small: class_pool n=1 checksum=6b3154a9 consumed=1 reads=0
`timescale 1ns/1ns
// A transaction generator and consumer: objects of two derived classes are
// created, held as base-class handles in a 16-entry ring buffer (a FIFO in a
// fixed array of handles) and consumed in order.
class holdout_txn;
  int unsigned id, payload;
  function new(int unsigned id, int unsigned payload);
    this.id = id;
    this.payload = payload;
  endfunction
  virtual function int unsigned weight();
    return payload ^ id;
  endfunction
endclass
class holdout_read extends holdout_txn;
  function new(int unsigned id, int unsigned payload);
    super.new(id, payload);
  endfunction
  virtual function int unsigned weight();
    return (payload >> 3) + id * 3;
  endfunction
endclass
class holdout_write extends holdout_txn;
  int unsigned mask;
  function new(int unsigned id, int unsigned payload);
    super.new(id, payload);
    mask = payload << 1;
  endfunction
  virtual function int unsigned weight();
    return (payload * 5) ^ mask ^ super.weight();
  endfunction
endclass
module class_pool;
  holdout_txn pool[16];
  int head = 0, count = 0;
  holdout_txn item;
  holdout_read r;
  holdout_write w;
  int n;
  int unsigned seed = 1, checksum = 0, consumed = 0, reads = 0;
  initial begin
    if (!$value$plusargs("n=%d", n)) n = 800000;
    for (int i = 1; i <= n; i++) begin
      seed = seed * 32'd1664525 + 32'd1013904223;
      if (seed[7]) begin
        r = new(i, seed);
        pool[(head + count) % 16] = r;
        count++;
        reads++;
      end else begin
        w = new(i, seed);
        pool[(head + count) % 16] = w;
        count++;
      end
      // Consume every third step, and always once the buffer holds nine.
      if (i % 3 == 0 || count > 8) begin
        item = pool[head];
        head = (head + 1) % 16;
        count--;
        checksum = (checksum * 33) ^ item.weight();
        consumed++;
      end
    end
    while (count > 0) begin
      item = pool[head];
      head = (head + 1) % 16;
      count--;
      checksum = (checksum * 33) ^ item.weight();
      consumed++;
    end
    $display("class_pool n=%0d checksum=%h consumed=%0d reads=%0d", n, checksum, consumed, reads);
    $finish;
  end
endmodule
