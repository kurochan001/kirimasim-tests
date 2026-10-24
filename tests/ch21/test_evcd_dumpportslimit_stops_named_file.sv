/*
:name: test_evcd_dumpportslimit_stops_named_file
:description: $dumpportslimit gives the largest size in bytes of the extended VCD file that its file name names; when the file reaches it, the dump stops and a comment that says so is written, so a port that changes at each of 1000 steps stops near 2000 bytes, before its last change, with a comment after it (IEEE 1800-2023 Section 21.7.3.4)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.3.4 21.7.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_evcd_dumpportslimit_stops_named_file.expected
*/
// IEEE 1800-2023 §21.7.3.4: the required integer argument of
// $dumpportslimit is the maximum size in bytes of the file that its second
// argument names, a string literal here; when that size is reached, the
// dumping stops and a comment is inserted in the file to say that the limit
// was attained. $dumpports (21.7.3.1) dumps the port of evcd_limit_one into
// the file, and $dumpportslimit(2000, <file>) limits it; the changes at the
// times 1 to 1000 would need far more than 2000 bytes.
// The port of each module is driven by a variable that is 0 at time 0 and
// toggles every nanosecond, so that the change at time t has the value
// t % 2 (U at odd times, D at even times, 21.7.4.3.1). The test reads each
// file token by token and finds the byte offset of each $comment with
// $ftell. For a file whose limit is reached it checks that the dump stopped
// before the last change, that every change up to the stop was dumped at
// its time, that a $comment follows the last change and nothing is dumped
// after it, and that the bytes before it are within 40 bytes of the limit:
// a tool can stop just before or just after the change that crosses the
// limit, and one time step of these files is shorter than 40 bytes. The
// comment text and the exact place of the stop depend on the tool and are
// not printed. For a file whose limit is not reached it checks that every
// change was dumped and that no comment follows the first change.
// No release of Icarus Verilog 13.0 or Verilator 5.052 implements
// $dumpports, so the expected output comes from the clauses alone.

`timescale 1ns / 1ns

module evcd_limit_one(input wire t);
endmodule

module test_evcd_dumpportslimit_stops_named_file;
  logic v = 1'b0;
  evcd_limit_one dut(.t(v));

  // Reads one extended VCD file of a single toggling port and prints where
  // its dump stopped and what follows the stop.
  task automatic check(string label, string file, int limit, int last);
    int fd, n = 0, out_of_order = 0, after = 0, t = 0, v, last_dumped = -1;
    int comment_at = -1;
    bit defs = 1;
    string tok, s0, s1, code;
    fd = $fopen(file, "r");
    while ($fscanf(fd, "%s", tok) == 1) begin
      if (tok == "$enddefinitions") begin
        defs = 0;
      end else if (tok == "$comment") begin
        if (!defs) begin
          comment_at = $ftell(fd) - 8;
          after = 0;
        end
        do void'($fscanf(fd, "%s", tok)); while (tok != "$end");
      end else if (!defs && tok.substr(0, 0) == "#") begin
        code = tok.substr(1, tok.len() - 1);
        t = code.atoi();
        if (comment_at >= 0) after++;
      end else if (!defs && tok.len() == 2 && tok.substr(0, 0) == "p") begin
        void'($fscanf(fd, "%s %s %s", s0, s1, code));
        v = tok[1] == "U" ? 1 : 0;
        if (v != t % 2 || t != last_dumped + 1) out_of_order++;
        last_dumped = t;
        n++;
        after = 0;
        comment_at = -1;
      end
    end
    $fclose(fd);
    $display("%0s: dump stopped before the last change: %0s", label,
             last_dumped > 0 && last_dumped < last ? "yes" : "no");
    $display("%0s: changes before the stop dumped in order: %0s", label,
             out_of_order == 0 && n == last_dumped + 1 ? "yes" : "no");
    $display("%0s: a comment follows the last dumped change: %0s", label,
             comment_at >= 0 ? "yes" : "no");
    $display("%0s: bytes before that comment within 40 of the limit: %0s", label,
             comment_at > limit - 40 && comment_at < limit + 40 ? "yes" : "no");
    $display("%0s: times or changes dumped after that comment: %0d", label, after);
  endtask

  // Reads one extended VCD file of a single toggling port whose limit is not
  // reached and prints the last change and the comments after the first one.
  task automatic check_full(string label, string file);
    int fd, n = 0, out_of_order = 0, late_comments = 0, t = 0, v, last_dumped = -1;
    bit defs = 1;
    string tok, s0, s1, code;
    fd = $fopen(file, "r");
    while ($fscanf(fd, "%s", tok) == 1) begin
      if (tok == "$enddefinitions") begin
        defs = 0;
      end else if (tok == "$comment") begin
        if (!defs && last_dumped > 0) late_comments++;
        do void'($fscanf(fd, "%s", tok)); while (tok != "$end");
      end else if (!defs && tok.substr(0, 0) == "#") begin
        code = tok.substr(1, tok.len() - 1);
        t = code.atoi();
      end else if (!defs && tok.len() == 2 && tok.substr(0, 0) == "p") begin
        void'($fscanf(fd, "%s %s %s", s0, s1, code));
        v = tok[1] == "U" ? 1 : 0;
        if (v != t % 2 || t != last_dumped + 1) out_of_order++;
        last_dumped = t;
        n++;
      end
    end
    $fclose(fd);
    $display("%0s: last dumped change at: %0d", label, last_dumped);
    $display("%0s: changes dumped in order: %0s", label,
             out_of_order == 0 && n == last_dumped + 1 ? "yes" : "no");
    $display("%0s: comments after the first change: %0d", label, late_comments);
  endtask

  initial begin
    $dumpports(dut, "test_evcd_dumpportslimit_stops_named_file.evcd");
    $dumpportslimit(2000, "test_evcd_dumpportslimit_stops_named_file.evcd");
    repeat (1000) #1 v = ~v;
    #1 $dumpportsflush;
    check("file", "test_evcd_dumpportslimit_stops_named_file.evcd", 2000, 1000);
  end
endmodule
