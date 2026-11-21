// Copyright (c) 2026 The kirimasim Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Original design. Independent oracle: bench/reference_holdout.py.
// spec_check: ai; IEEE 1800-2023 8 (classes, inheritance, virtual methods) and 7.10 (queues).
// bench-n: 400000
// bench-expect: class_pool n=400000 checksum=5b3ef168 consumed=400000 reads=199997
// bench-expect-small: class_pool n=1 checksum=6b3154a9 consumed=1 reads=0
`timescale 1ns/1ns
// A transaction generator and consumer: objects of two derived classes are
// created, held as base-class handles in a queue and consumed in order.
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
  holdout_txn pool[$];
  holdout_txn item;
  holdout_read r;
  holdout_write w;
  int n;
  int unsigned seed = 1, checksum = 0, consumed = 0, reads = 0;
  initial begin
    if (!$value$plusargs("n=%d", n)) n = 400000;
    for (int i = 1; i <= n; i++) begin
      seed = seed * 32'd1664525 + 32'd1013904223;
      if (seed[7]) begin
        r = new(i, seed);
        pool.push_back(r);
        reads++;
      end else begin
        w = new(i, seed);
        pool.push_back(w);
      end
      // Consume every third step, and always once the queue holds eight.
      if (i % 3 == 0 || pool.size() > 8) begin
        item = pool.pop_front();
        checksum = (checksum * 33) ^ item.weight();
        consumed++;
      end
    end
    while (pool.size() > 0) begin
      item = pool.pop_front();
      checksum = (checksum * 33) ^ item.weight();
      consumed++;
    end
    $display("class_pool n=%0d checksum=%h consumed=%0d reads=%0d", n, checksum, consumed, reads);
    $finish;
  end
endmodule
