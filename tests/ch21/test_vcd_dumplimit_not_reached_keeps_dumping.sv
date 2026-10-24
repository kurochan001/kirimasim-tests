/*
:name: test_vcd_dumplimit_not_reached_keeps_dumping
:description: $dumplimit stops the dump only when the VCD file reaches the given size, so under a limit far above the size of the whole dump every change of a counter is dumped and no comment comes after the first change (IEEE 1800-2023 Section 21.7.1.5)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.1.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vcd_dumplimit_not_reached_keeps_dumping.expected
*/
// IEEE 1800-2023 §21.7.1.5: the argument of $dumplimit is the maximum size
// of the VCD file in bytes, and the dumping stops, with a comment that says
// so, when the file reaches that size. This is the other side of the limit
// from test_vcd_dumplimit_stops_dump_with_comment: the 16-bit counter c
// takes the value of the simulation time at every step from 1 to 50 ns, a
// dump of a few hundred bytes, under a limit of 100000 bytes, which the
// file never reaches. The test reads the file token by token and checks
// that every change was dumped at its time, up to the last value 50, and
// that no $comment follows the first change, as a comment about the limit
// would. A comment that the tool writes before the first value change is
// allowed and ignored.

`timescale 1ns / 1ns

module test_vcd_dumplimit_not_reached_keeps_dumping;
  logic [15:0] c = 16'd0;

  task automatic check(string file);
    int fd, n = 0, out_of_order = 0, late_comments = 0, t = 0, v, last_dumped = -1;
    bit defs = 1;
    string tok, id;
    fd = $fopen(file, "r");
    while ($fscanf(fd, "%s", tok) == 1) begin
      if (tok == "$enddefinitions") begin
        defs = 0;
      end else if (tok == "$comment") begin
        if (!defs && last_dumped > 0) late_comments++;
        do void'($fscanf(fd, "%s", tok)); while (tok != "$end");
      end else if (!defs && tok.substr(0, 0) == "#") begin
        id = tok.substr(1, tok.len() - 1);
        t = id.atoi();
      end else if (!defs && (tok[0] == "b" || tok[0] == "B")) begin
        void'($fscanf(fd, "%s", id));
        v = 0;
        for (int k = 1; k < tok.len(); k++) v = v * 2 + (tok[k] == "1");
        if (v != t || v != last_dumped + 1) out_of_order++;
        last_dumped = v;
        n++;
      end
    end
    $fclose(fd);
    $display("last dumped value: %0d", last_dumped);
    $display("changes dumped in order at their times: %0s",
             out_of_order == 0 && n == last_dumped + 1 ? "yes" : "no");
    $display("comments after the first change: %0d", late_comments);
  endtask

  initial begin
    $dumpfile("test_vcd_dumplimit_not_reached_keeps_dumping.vcd");
    $dumpvars(0, test_vcd_dumplimit_not_reached_keeps_dumping.c);
    $dumplimit(100000);
    repeat (50) #1 c = c + 16'd1;
    #1 $dumpflush;
    check("test_vcd_dumplimit_not_reached_keeps_dumping.vcd");
  end
endmodule
