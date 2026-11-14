/*
:name: test_vcd_comment_section_after_dump_limit
:description: When the VCD file reaches the size set by $dumplimit, the dumper inserts its comment as a $comment section, the keyword followed by the comment text and $end, after the changes it dumped (IEEE 1800-2023 Sections 21.7.2.3 and 21.7.1.5)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.2.3 21.7.1.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vcd_comment_section_after_dump_limit.expected
*/
// IEEE 1800-2023 §21.7.2.3: a comment is inserted in a VCD file as a $comment
// section, the keyword $comment, the text of the comment and $end.
// §21.7.1.5: when the VCD file reaches the size that $dumplimit gives, the
// dumping stops and a comment saying that the limit was reached is inserted
// in the file. The test dumps the 16-bit variable c, which changes at each of
// 300 steps, under a limit of 1000 bytes, far less than these changes need,
// and flushes the file. A reader takes the file token by token and looks for
// a $comment that comes after at least one dumped time or value change (a
// tool may write comments of its own among the declarations or before the
// first time). It prints whether such a comment was found, whether its text
// had at least one token and whether the section ended with $end. The text
// itself and the place where the dump stopped depend on the tool and are not
// printed. The file is created in the current directory.
// Icarus Verilog 13.0 also prints a message of its own about the limit on
// the standard output, which the runner does not remove, so it does not
// match. The 5.054 release of Verilator, built without --trace as the runner
// builds it, ignores $dumpvars and writes no file.

`timescale 1ns / 1ns

module test_vcd_comment_section_after_dump_limit;
  logic [15:0] c = 16'd0;

  task automatic check(string file);
    int fd, rc, words = 0;
    bit defs = 1, dumped = 0, found = 0, closed = 0;
    string tok;
    fd = $fopen(file, "r");
    if (fd == 0) $fatal(1, "the dump file is missing");
    while ($fscanf(fd, "%s", tok) == 1) begin
      if (tok == "$enddefinitions") begin
        defs = 0;
      end else if (tok == "$comment") begin
        if (!defs && dumped && !found) begin
          found = 1;
          forever begin
            rc = $fscanf(fd, "%s", tok);
            if (rc != 1) break;
            if (tok == "$end") begin
              closed = 1;
              break;
            end
            words++;
          end
        end else begin
          do rc = $fscanf(fd, "%s", tok); while (rc == 1 && tok != "$end");
        end
      end else if (!defs && tok[0] == "#") begin
        dumped = 1;
      end
    end
    $fclose(fd);
    $display("a $comment section after dumped changes: %0s", found ? "yes" : "no");
    $display("its comment text is not empty: %0s", words > 0 ? "yes" : "no");
    $display("it ends with $end: %0s", closed ? "yes" : "no");
  endtask

  initial begin
    $dumpfile("test_vcd_comment_section_after_dump_limit.vcd");
    $dumpvars(0, test_vcd_comment_section_after_dump_limit.c);
    $dumplimit(1000);
    repeat (300) #1 c = c + 16'd1;
    #1 $dumpflush;
    check("test_vcd_comment_section_after_dump_limit.vcd");
  end
endmodule
