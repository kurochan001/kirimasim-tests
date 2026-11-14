/*
:name: test_evcd_dumpports_bare_call_defaults
:description: $dumpports written without arguments or parentheses uses the default arguments, dumping the ports of the calling module into dumpports.vcd, and $dumpports with an empty first argument followed by a comma and a file name dumps the ports of its own calling module into that file (IEEE 1800-2023 Section 21.7.3.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_evcd_dumpports_bare_call_defaults.expected
*/
// IEEE 1800-2023 §21.7.3.1: both arguments of $dumpports are optional. The
// task can be written as $dumpports; with no arguments, and then the default
// of each argument is used: the scope is the module that calls the task and
// the file is dumpports.vcd in the current working directory. When the scope
// list is left out but a file name is given, a comma comes before the file
// name. The ports of the scope are dumped and those of other modules are not;
// several calls run at the same time with different scopes and file names.
// Here the instance ua of evcd_bare_a calls $dumpports; and the instance ub of
// evcd_bare_b calls $dumpports(, <file name>), both at time 0. After
// $dumpportsflush (§21.7.3.5) the test reads each file token by token,
// white space separating them (§21.7.4), and prints its $var entries in the
// order of their identifier codes (§21.7.4.2: the type port, the size 1 of a
// scalar, the code <0, <1, ... in the order of the module declaration, and the
// port name). The scope names and the other sections, which the tool
// formats, are not printed. The files are created in the current directory.
// Icarus Verilog 13.0 does not implement $dumpports (it reports the task as
// not implemented), and the 5.054 release of Verilator rejects $dumpports; as a
// syntax error although §21.7.3.1 allows it, so the expected output comes
// from the clauses alone.

`timescale 1ns / 1ns

module evcd_bare_a(input wire p, output wire q);
  assign q = ~p;
  initial $dumpports;
endmodule

module evcd_bare_b(input wire r);
  initial $dumpports(, "test_evcd_dumpports_bare_call_defaults_b.evcd");
endmodule

module test_evcd_dumpports_bare_call_defaults;
  logic vp = 1'b0, vr = 1'b1;
  wire q;

  evcd_bare_a ua(.p(vp), .q(q));
  evcd_bare_b ub(.r(vr));

  // Prints the $var entries of an extended VCD file by identifier code. The
  // code is an integer after <, which is joined to it if written apart.
  task show_ports(string file);
    int fd, rc, number;
    string tok, code, digits;
    string by_code[8];
    string parts[$];
    foreach (by_code[n]) by_code[n] = "";
    fd = $fopen(file, "r");
    if (fd == 0) begin
      $display("%s: no file", file);
      return;
    end
    while ($fscanf(fd, "%s", tok) == 1 && tok != "$enddefinitions") begin
      if (tok == "$var") begin
        parts.delete();
        while ($fscanf(fd, "%s", tok) == 1 && tok != "$end") parts.push_back(tok);
        if (parts.size() < 4) begin
          $display("%s: malformed $var", file);
        end else begin
          code = "";
          for (int i = 2; i < parts.size() - 1; i++) code = {code, parts[i]};
          digits = code.substr(1, code.len() - 1);
          number = digits.atoi();
          if (number >= 0 && number < 8)
            by_code[number] = $sformatf("var %s %s %s %s", parts[0], parts[1], code,
                                        parts[parts.size() - 1]);
          else
            $display("%s: code %s out of range", file, code);
        end
      end else if (tok.len() > 1 && tok[0] == "$") begin
        do rc = $fscanf(fd, "%s", tok); while (rc == 1 && tok != "$end");
      end
    end
    $fclose(fd);
    $display("%s:", file);
    foreach (by_code[n]) if (by_code[n] != "") $display("%s", by_code[n]);
  endtask

  initial begin
    #1 $dumpportsflush;
    show_ports("dumpports.vcd");
    show_ports("test_evcd_dumpports_bare_call_defaults_b.evcd");
  end
endmodule
