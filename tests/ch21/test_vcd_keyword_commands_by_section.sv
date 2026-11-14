/*
:name: test_vcd_keyword_commands_by_section
:description: In a four-state VCD file the declaration keyword commands $date, $timescale, $upscope and $var come before $enddefinitions, which comes before the first time and value change, and the simulation keyword commands $dumpoff, $dumpon and $dumpall come after it (IEEE 1800-2023 Section 21.7.2.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.2.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vcd_keyword_commands_by_section.expected
*/
// IEEE 1800-2023 §21.7.2.3, Table 21-10: the keyword commands of a VCD file
// are declaration keywords ($comment, $date, $enddefinitions, $scope,
// $timescale, $upscope, $var and $version) and simulation keywords ($dumpall,
// $dumpoff, $dumpon and $dumpvars); $enddefinitions ends the header and the
// definitions. Declaration commands therefore come before $enddefinitions and
// simulation commands after it (the grammar of §21.7.2.1 puts every
// declaration command before every simulation command, and the header gives
// the date and the timescale).
// The test dumps a module with a nested instance, so the definitions have a
// $upscope, changes a vector, and calls $dumpoff, $dumpon and $dumpall at
// later times before it flushes the file. A reader then takes the file token
// by token: each keyword (a token that starts with $, other than $end) and
// the text up to its $end form one command, a token that starts with b, B, r
// or R is a vector or real value change whose identifier code follows, and
// any other token is a time or a scalar value change. It records the
// position of each command and prints, for each keyword of interest, whether
// all its commands come before $enddefinitions, all after it, or neither;
// for $enddefinitions it prints how many there are and whether one comes
// before every time and value change. Neither the order of the declarations
// among themselves, the identifier codes nor the number of scopes is printed.
// The 5.054 release of Verilator, built without --trace as the runner builds
// it, ignores $dumpvars and writes no file, so it does not confirm the output.

`timescale 1ns/1ns

module vcd_keyword_leaf;
  logic leaf_bit = 1'b0;
endmodule

module vcd_keyword_mid;
  logic [3:0] mid_vec = 4'd0;
  vcd_keyword_leaf leaf();
endmodule

module test_vcd_keyword_commands_by_section;
  vcd_keyword_mid mid();

  string names[8] = '{"$date", "$timescale", "$upscope", "$var", "$enddefinitions",
                      "$dumpoff", "$dumpon", "$dumpall"};
  int first_pos[8], last_pos[8], count[8];

  task automatic read_dump();
    int fd, rc, pos = 0, first_other = -1, k;
    string tok;
    foreach (names[i]) begin
      first_pos[i] = -1;
      last_pos[i] = -1;
      count[i] = 0;
    end
    fd = $fopen("test_vcd_keyword_commands_by_section.vcd", "r");
    if (fd == 0) $fatal(1, "the dump file is missing");
    while ($fscanf(fd, "%s", tok) == 1) begin
      pos++;
      if (tok[0] == "b" || tok[0] == "B" || tok[0] == "r" || tok[0] == "R") begin
        // A vector or real value change; its identifier code is the next token.
        rc = $fscanf(fd, "%s", tok);
        if (first_other < 0) first_other = pos;
      end else if (tok[0] == "$" && tok != "$end") begin
        k = -1;
        foreach (names[i]) if (names[i] == tok) k = i;
        if (k >= 0) begin
          if (first_pos[k] < 0) first_pos[k] = pos;
          last_pos[k] = pos;
          count[k]++;
        end
        do rc = $fscanf(fd, "%s", tok); while (rc == 1 && tok != "$end");
      end else if (first_other < 0) begin
        first_other = pos;
      end
    end
    $fclose(fd);
    foreach (names[i]) begin
      if (i == 4)
        $display("%s: %0d, before the first time or value change: %0d", names[i], count[i],
                 first_pos[i] > 0 && (first_other < 0 || first_pos[i] < first_other));
      else if (count[i] == 0)
        $display("%s: absent", names[i]);
      else if (last_pos[i] < first_pos[4])
        $display("%s: before $enddefinitions", names[i]);
      else if (first_pos[i] > last_pos[4])
        $display("%s: after $enddefinitions", names[i]);
      else
        $display("%s: on both sides of $enddefinitions", names[i]);
    end
  endtask

  initial begin
    $dumpfile("test_vcd_keyword_commands_by_section.vcd");
    $dumpvars(0, mid);
    #1 mid.mid_vec = 4'd5;
    #1 $dumpoff;
    #1 mid.mid_vec = 4'd6;
    #1 $dumpon;
    #1 $dumpall;
    #1 $dumpflush;
    read_dump();
  end
endmodule
