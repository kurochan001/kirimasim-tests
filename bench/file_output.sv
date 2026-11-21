// Copyright (c) 2026 The kirimasim Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Original design. Independent oracle: bench/reference_holdout.py.
// spec_check: ai; IEEE 1800-2023 21.2 ($sformatf, %0d/%h/%s), 21.3 ($fopen, $fwrite, $ftell, $fgets).
// bench-n: 1000000
// bench-expect: file_output n=1000000 lines=1000000 bytes=27469311 checksum=b0fac4c3
// bench-expect-small: file_output n=1 lines=1 bytes=22 checksum=00000016
`timescale 1ns/1ns
// Formats one line per step with $sformatf and writes it with $fwrite to a
// file in the working directory; then reads the file back and prints only
// the line count, the byte count and a checksum of the line lengths.
module file_output;
  string words[4] = '{"alpha", "beta", "gamma", "delta"};
  string line;
  logic [31:0] seed = 1, checksum = 0;
  int n, fd, bytes, lines = 0;
  initial begin
    if (!$value$plusargs("n=%d", n)) n = 1000000;
    fd = $fopen("file_output.txt", "w");
    if (fd == 0) $fatal(1, "file_output: cannot open the output file");
    for (int i = 1; i <= n; i++) begin
      seed = seed * 32'd1664525 + 32'd1013904223;
      line = $sformatf("%0d:%h:%s:%0d", i, seed, words[seed[9:8]], seed[15:0]);
      $fwrite(fd, "%s\n", line);
    end
    bytes = $ftell(fd);
    $fclose(fd);
    fd = $fopen("file_output.txt", "r");
    if (fd == 0) $fatal(1, "file_output: cannot read the output file");
    while ($fgets(line, fd) > 0) begin
      lines++;
      checksum = (checksum * 33) ^ line.len();
    end
    $fclose(fd);
    $display("file_output n=%0d lines=%0d bytes=%0d checksum=%h", n, lines, bytes, checksum);
    $finish;
  end
endmodule
