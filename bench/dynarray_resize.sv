// Copyright (c) 2026 The kirimasim Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Original design. Independent oracle: bench/reference_holdout.py.
// spec_check: ai; IEEE 1800-2023 7.5 (dynamic arrays: new[], resize, size, delete) and 7.6 (copies).
// bench-n: 120000
// bench-expect: dynarray_resize n=120000 checksum=5dd37c41 size=3 sizes=1020283
// bench-expect-small: dynarray_resize n=1 checksum=3c3d1f51 size=10 sizes=10
`timescale 1ns/1ns
// A dynamic array is resized every step, keeping its first elements with
// new[size](data) or starting fresh with new[size], updated with foreach,
// copied (a copy is a new array), folded into a checksum and sometimes
// deleted. No queue or associative array is used.
module dynarray_resize;
  int unsigned data[], copy[];
  int unsigned seed = 1, checksum = 0, sizes = 0, size;
  int n;
  initial begin
    if (!$value$plusargs("n=%d", n)) n = 120000;
    data = new[4];
    foreach (data[k]) data[k] = k;
    for (int i = 1; i <= n; i++) begin
      seed = seed * 32'd1664525 + 32'd1013904223;
      size = (seed >> 8) % 16 + 1;
      if (seed[3]) data = new[size](data);
      else data = new[size];
      foreach (data[k]) data[k] = data[k] * 3 + (seed ^ k);
      if (i % 7 == 0) begin
        copy = data;
        copy[0] = copy[0] + 1;
        checksum = checksum ^ copy[0] ^ data[0];
      end
      foreach (data[k]) checksum = (checksum * 33) ^ data[k];
      sizes = sizes + data.size();
      if (i % 11 == 0) data.delete();
    end
    $display("dynarray_resize n=%0d checksum=%h size=%0d sizes=%0d", n, checksum, data.size(), sizes);
    $finish;
  end
endmodule
