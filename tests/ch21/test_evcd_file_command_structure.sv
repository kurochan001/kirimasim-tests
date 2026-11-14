/*
:name: test_evcd_file_command_structure
:description: An extended VCD file has all its declaration commands before its simulation commands, closes every keyword command with $end, and after the declarations holds only the port dump sections $dumpports, $dumpportsoff, $dumpportson and $dumpportsall, comments, times and port value changes of a state character, two strength components and a declared identifier code (IEEE 1800-2023 Section 21.7.4.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_evcd_file_command_structure.expected
*/
// IEEE 1800-2023 §21.7.4.1, Syntax 21-27: an extended VCD file is a sequence
// of declaration commands followed by a sequence of simulation commands. A
// declaration command is a declaration keyword ($comment, $date,
// $enddefinitions, $scope, $timescale, $upscope, $var, $vcdclose or $version)
// with its text and $end. A simulation command is a simulation keyword
// ($dumpports, $dumpportsoff, $dumpportson or $dumpportsall) with value
// changes and $end, a $comment with its text and $end, a time (# and a
// decimal number) or a value change; a value change is p and a state
// character (D U N Z d u, L H X T l h, or 0 1 ? F A a B b C c f), a 0 and a
// 1 strength component (0 to 7) and the identifier code, < and an integer.
// The test dumps the ports of dut with $dumpports at time 0, changes the
// input at 1, calls $dumpportsoff at 2 (a checkpoint with x values,
// §21.7.3.2), changes the input at 3, calls $dumpportson at 4 and
// $dumpportsall at 5 (§21.7.3.3), and flushes the file at 6 (§21.7.3.5). As
// in four-state VCD, whose rules apply unless a clause says otherwise
// (§21.7.3, §21.7.2.3), the initial values and these checkpoints are
// sections of the keywords $dumpports, $dumpportsoff, $dumpportson and
// $dumpportsall. The test then reads the file token by token, white space
// separating them (§21.7.4), and prints whether every declaration command
// came before the first simulation command, whether every keyword command
// ended with $end, which of the four sections occurred, whether the times
// were decimal and increasing, whether every value change had a valid state
// character, two strength digits and the code of a declared port, and the
// number of tokens that fit none of these. It does not print the text of
// the declarations, the times or the values, which other clauses fix or the
// tool formats. The file is created in the current directory.
// Icarus Verilog 13.0 does not implement $dumpports (and does not compile the
// inside operator of the reader), and the 5.054 release of Verilator, built
// without --trace as the runner builds it, ignores $dumpports and writes no
// file, so the expected output comes from the clauses alone.

`timescale 1ns / 1ns

module evcd_structure_dut(input wire a, output wire y);
  assign y = ~a;
endmodule

module test_evcd_file_command_structure;
  logic a = 1'b0;
  wire y;

  evcd_structure_dut dut(.a(a), .y(y));

  string codes[$];
  bit unterminated = 0, bad_change = 0;

  // Reads the tokens up to $end into parts; notes a command without $end.
  task read_to_end(int fd, output string parts[$]);
    string tok;
    parts.delete();
    forever begin
      if ($fscanf(fd, "%s", tok) != 1) begin
        unterminated = 1;
        return;
      end
      if (tok == "$end") return;
      parts.push_back(tok);
    end
  endtask

  // Checks the rest of a value change whose first token is tok.
  task check_change(int fd, string tok);
    string s0, s1, code, number;
    bit known;
    known = 0;
    if (tok.len() != 2 || !(tok[1] inside {"D", "U", "N", "Z", "d", "u", "L", "H", "X", "T",
                                          "l", "h", "0", "1", "?", "F", "A", "a", "B", "b",
                                          "C", "c", "f"})) bad_change = 1;
    if ($fscanf(fd, "%s %s %s", s0, s1, code) != 3) begin
      bad_change = 1;
      return;
    end
    if (code == "<") begin
      if ($fscanf(fd, "%s", number) != 1) bad_change = 1;
      code = {code, number};
    end
    if (s0.len() != 1 || s1.len() != 1 || !(s0[0] inside {["0":"7"]}) ||
        !(s1[0] inside {["0":"7"]})) bad_change = 1;
    foreach (codes[i]) if (codes[i] == code) known = 1;
    if (!known) bad_change = 1;
  endtask

  task check_file(string file);
    int fd, t, last_time, changes, other;
    string tok, digits, code;
    string parts[$];
    bit in_declarations, declaration_late, bad_time;
    bit seen_ports, seen_off, seen_on, seen_all;
    last_time = -1;
    changes = 0;
    other = 0;
    in_declarations = 1;
    declaration_late = 0;
    bad_time = 0;
    {seen_ports, seen_off, seen_on, seen_all} = 4'b0000;
    fd = $fopen(file, "r");
    if (fd == 0) begin
      $display("no file");
      return;
    end
    while ($fscanf(fd, "%s", tok) == 1) begin
      if (tok == "$comment") begin
        read_to_end(fd, parts);
      end else if (tok == "$date" || tok == "$enddefinitions" || tok == "$scope" ||
                   tok == "$timescale" || tok == "$upscope" || tok == "$var" ||
                   tok == "$vcdclose" || tok == "$version") begin
        if (!in_declarations) declaration_late = 1;
        read_to_end(fd, parts);
        if (tok == "$var" && parts.size() >= 4) begin
          code = "";
          for (int i = 2; i < parts.size() - 1; i++) code = {code, parts[i]};
          codes.push_back(code);
        end
      end else if (tok == "$dumpports" || tok == "$dumpportsoff" || tok == "$dumpportson" ||
                   tok == "$dumpportsall") begin
        in_declarations = 0;
        if (tok == "$dumpports") seen_ports = 1;
        if (tok == "$dumpportsoff") seen_off = 1;
        if (tok == "$dumpportson") seen_on = 1;
        if (tok == "$dumpportsall") seen_all = 1;
        forever begin
          if ($fscanf(fd, "%s", tok) != 1) begin
            unterminated = 1;
            break;
          end
          if (tok == "$end") break;
          if (tok[0] == "p") begin
            check_change(fd, tok);
            changes++;
          end else begin
            other++;
          end
        end
      end else if (tok[0] == "#") begin
        in_declarations = 0;
        digits = tok.substr(1, tok.len() - 1);
        if (digits.len() == 0) bad_time = 1;
        for (int i = 0; i < digits.len(); i++) if (!(digits[i] inside {["0":"9"]})) bad_time = 1;
        t = digits.atoi();
        if (t <= last_time) bad_time = 1;
        last_time = t;
      end else if (tok[0] == "p") begin
        in_declarations = 0;
        check_change(fd, tok);
        changes++;
      end else begin
        other++;
      end
    end
    $fclose(fd);
    $display("declarations before the first simulation command: %0s",
             declaration_late ? "no" : "yes");
    $display("every keyword command ends with $end: %0s", unterminated ? "no" : "yes");
    $display("sections: $dumpports %0s, $dumpportsoff %0s, $dumpportson %0s, $dumpportsall %0s",
             seen_ports ? "yes" : "no", seen_off ? "yes" : "no", seen_on ? "yes" : "no",
             seen_all ? "yes" : "no");
    $display("times are # and a decimal number, increasing: %0s", bad_time ? "no" : "yes");
    $display("value changes are p, a state, two strengths and a declared code: %0s",
             changes > 0 && !bad_change ? "yes" : "no");
    $display("tokens outside the syntax: %0d", other);
  endtask

  initial begin
    $dumpports(dut, "test_evcd_file_command_structure.evcd");
    #1 a = 1'b1;
    #1 $dumpportsoff;
    #1 a = 1'b0;
    #1 $dumpportson;
    #1 $dumpportsall;
    #1 $dumpportsflush;
    check_file("test_evcd_file_command_structure.evcd");
  end
endmodule
