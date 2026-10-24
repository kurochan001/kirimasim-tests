/*
:name: test_vcd_dumplimit_stops_dump_with_comment
:description: $dumplimit gives the largest size of the VCD file in bytes; when the file reaches it, dumping stops and a comment that says so is written, so a counter dumped at each of 1000 steps stops near 2000 bytes, before its last value, with a comment after its last change (IEEE 1800-2023 Section 21.7.1.5)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.1.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vcd_dumplimit_stops_dump_with_comment.expected
*/
// IEEE 1800-2023 §21.7.1.5: the argument of $dumplimit is the maximum size
// of the VCD file in bytes; when the file reaches that size, the dumping
// stops and a comment is inserted in the file to say that the limit was
// reached. The test dumps only the 16-bit counter c (21.7.1.2), which takes
// the value of the simulation time at every step from 1 to 1000 ns, under a
// limit of 2000 bytes; all of these changes would need far more than that.
// It then reads the file token by token and finds the byte offset of each
// $comment with $ftell. It checks that the dump stopped before the last
// value, that every change up to the stop was dumped at its time, that a
// $comment follows the last change and nothing is dumped after it, and that
// the bytes before it are within 40 bytes of the limit: a tool can stop
// just before or just after the change that crosses 2000 bytes, and one
// time step of this dump is shorter than 40 bytes. The comment text and
// the exact place of the stop depend on the tool and are not printed.
// Icarus Verilog 13.0 prints the five expected lines, but it also prints a
// warning of its own about the limit on the standard output, which the
// runner does not remove, so the test does not match it.

`timescale 1ns / 1ns

module test_vcd_dumplimit_stops_dump_with_comment;
  logic [15:0] c = 16'd0;

  task automatic check(string file, int limit, int last);
    int fd, n = 0, out_of_order = 0, after = 0, t = 0, v;
    int comment_at = -1, last_dumped = -1;
    bit defs = 1;
    string tok, id;
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
        id = tok.substr(1, tok.len() - 1);
        t = id.atoi();
        if (comment_at >= 0) after++;
      end else if (!defs && (tok[0] == "b" || tok[0] == "B")) begin
        void'($fscanf(fd, "%s", id));
        v = 0;
        for (int k = 1; k < tok.len(); k++) v = v * 2 + (tok[k] == "1");
        if (v != t || v != last_dumped + 1) out_of_order++;
        last_dumped = v;
        n++;
        after = 0;
        comment_at = -1;
      end
    end
    $fclose(fd);
    $display("dump stopped before the last change: %0s",
             last_dumped > 0 && last_dumped < last ? "yes" : "no");
    $display("changes before the stop dumped in order at their times: %0s",
             out_of_order == 0 && n == last_dumped + 1 ? "yes" : "no");
    $display("a comment follows the last dumped change: %0s", comment_at >= 0 ? "yes" : "no");
    $display("bytes before that comment within 40 of the limit: %0s",
             comment_at > limit - 40 && comment_at < limit + 40 ? "yes" : "no");
    $display("times or changes dumped after that comment: %0d", after);
  endtask

  initial begin
    $dumpfile("test_vcd_dumplimit_stops_dump_with_comment.vcd");
    $dumpvars(0, test_vcd_dumplimit_stops_dump_with_comment.c);
    $dumplimit(2000);
    repeat (1000) #1 c = c + 16'd1;
    #1 $dumpflush;
    check("test_vcd_dumplimit_stops_dump_with_comment.vcd", 2000, 1000);
  end
endmodule
