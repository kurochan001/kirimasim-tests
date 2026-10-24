/*
:name: test_evcd_dumpports_files_defaults_and_control_scope
:description: Four $dumpports calls at time 0 name their files by a string variable, an integral variable holding a character string, a string literal after an empty scope argument, and no argument at all, which selects the calling module and the file dumpports.vcd, overwriting the file there; $dumpportsoff, $dumpportson(), $dumpportsall and $dumpportsflush without a file name act on all four files, with a file name only on that file, and $dumpvars dumps into its own VCD file meanwhile (IEEE 1800-2023 Sections 21.7.3.1 to 21.7.3.7)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.3.1 21.7.3.2 21.7.3.3 21.7.3.5 21.7.3.7 21.7.4.3 21.7.4.3.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_evcd_dumpports_files_defaults_and_control_scope.expected
*/
// IEEE 1800-2023 §21.7.3.1: the scope list and the file name of $dumpports
// are optional. The file name is an expression that is a string literal, a
// string or an integral value holding a character string; without one the
// file is dumpports.vcd in the current working directory, overwritten
// without notice if it exists. Without a scope list the scope is the module
// that calls $dumpports, and a comma comes before the file name when the
// scope list is left out. Several calls have to execute at the same time,
// with different scopes and files, and $dumpports can be used together
// with $dumpvars. §21.7.3.7: a task with only optional arguments can be
// written with no arguments or with empty parentheses. Here the top module
// opens file a for the ports of ua, named by a string variable, and file b
// for ub, named by an integral variable; uc first writes a line of text to
// dumpports.vcd and then calls $dumpports(), and ud calls $dumpports(,
// <literal>). All four calls run at time 0, and the top module also dumps
// the variable vp with $dumpvars.
// §21.7.3.2, §21.7.3.3 and §21.7.3.5: without a file name, $dumpportsoff
// (20) suspends, $dumpportson() (30) resumes, $dumpportsall (40) checkpoints
// and $dumpportsflush (70) flushes every file that $dumpports opened; with
// a file name, $dumpportsall (50, 60), $dumpportsoff (52), $dumpportson
// (62) and $dumpportsflush (65) act only on that file. The changes at 25,
// made while the port dump is off, are not in any port file, but $dumpvars
// still
// records vp at 25; the changes at 55 are in the files that are not
// suspended. In a checkpoint of $dumpportsoff each port has an x value, N
// for an input and X for an output (21.7.4.3.1); its strengths are not
// printed. The values are p, the state character, the strength0 and the
// strength1 components (21.7.4.3), with the drivers of strong strength
// that the port connections make.
// After the last flush the test reads each port file token by token,
// prints its $var entries and the values at each time and in each section,
// sorted by identifier code, and counts the tokens that are not a command,
// a time or a port value change, which would include the old text of
// dumpports.vcd. It then prints the changes of vp in the VCD file.
// No release of Icarus Verilog 13.0 or Verilator 5.052 implements
// $dumpports, so the expected output comes from the clauses alone.

`timescale 1ns / 1ns

module evcd_files_a(input wire p, output wire q);
  assign q = ~p;
endmodule

module evcd_files_b(input wire r);
endmodule

module evcd_files_c(input wire s);
  initial begin
    int fd;
    fd = $fopen("dumpports.vcd", "w");
    $fwrite(fd, "an old file\n");
    $fclose(fd);
    $dumpports();
  end
endmodule

module evcd_files_d(output wire t);
  logic tv = 1'b0;
  assign t = tv;
  initial $dumpports(, "test_evcd_dumpports_files_defaults_and_control_scope_d.evcd");
endmodule

module test_evcd_dumpports_files_defaults_and_control_scope;
  string fname_a = "test_evcd_dumpports_files_defaults_and_control_scope_a.evcd";
  logic [8*59:1] fname_b = "test_evcd_dumpports_files_defaults_and_control_scope_b.evcd";
  logic vp = 1'b0, vr = 1'b0, vs = 1'b0;
  wire q, t;
  string names[$], codes[$], vals[$];

  evcd_files_a ua(.p(vp), .q(q));
  evcd_files_b ub(.r(vr));
  evcd_files_c uc(.s(vs));
  evcd_files_d ud(.t(t));

  function automatic int find(string code);
    foreach (codes[k]) if (codes[k] == code) return k;
    return -1;
  endfunction

  function automatic int code_number(string code);
    string digits = code.substr(1, code.len() - 1);
    return digits.atoi();
  endfunction

  task automatic flush(int t, string section);
    string line;
    bit any = 0;
    line = $sformatf("#%0d", t);
    if (section != "") line = {line, " ", section};
    line = {line, ":"};
    for (int n = 0; n < codes.size(); n++)
      foreach (codes[k])
        if (code_number(codes[k]) == n && vals[k] != "") begin
          line = {line, " ", names[k], "=", vals[k]};
          vals[k] = "";
          any = 1;
        end
    if (any) $display("%s", line);
  endtask

  task automatic read_ports(string label, string file);
    int fd, k, t = 0, malformed = 0;
    string tok, typ, size, code, ref_name, s0, s1, section = "";
    names.delete();
    codes.delete();
    vals.delete();
    $display("file %0s:", label);
    fd = $fopen(file, "r");
    while ($fscanf(fd, "%s", tok) == 1) begin
      if (tok == "$var") begin
        void'($fscanf(fd, "%s %s %s %s", typ, size, code, ref_name));
        names.push_back(ref_name);
        codes.push_back(code);
        vals.push_back("");
        $display("var %0s %0s %0s %0s", typ, size, code, ref_name);
        do void'($fscanf(fd, "%s", tok)); while (tok != "$end");
      end else if (tok == "$date" || tok == "$version" || tok == "$timescale" ||
                   tok == "$scope" || tok == "$upscope" || tok == "$comment" ||
                   tok == "$enddefinitions" || tok == "$vcdclose") begin
        do void'($fscanf(fd, "%s", tok)); while (tok != "$end");
      end else if (tok.substr(0, 0) == "#" && tok.len() > 1) begin
        flush(t, section);
        tok = tok.substr(1, tok.len() - 1);
        t = tok.atoi();
      end else if (tok == "$dumpports" || tok == "$dumpportsoff" || tok == "$dumpportson" ||
                   tok == "$dumpportsall") begin
        flush(t, section);
        section = tok;
      end else if (tok == "$end") begin
        flush(t, section);
        section = "";
      end else if (tok.len() == 2 && tok.substr(0, 0) == "p") begin
        void'($fscanf(fd, "%s %s %s", s0, s1, code));
        k = find(code);
        if (k < 0) malformed++;
        else if (section == "$dumpportsoff") vals[k] = tok.substr(1, 1);
        else vals[k] = {tok, " ", s0, " ", s1};
      end else begin
        malformed++;
      end
    end
    flush(t, section);
    $fclose(fd);
    $display("tokens that are not a command, a time or a port value change: %0d", malformed);
  endtask

  // Prints the changes of the one scalar variable of a 4-state VCD file.
  task automatic read_vars(string file);
    int fd, t = 0;
    bit defs = 1;
    string tok, line = "vp in the VCD file:";
    fd = $fopen(file, "r");
    while ($fscanf(fd, "%s", tok) == 1) begin
      if (tok == "$enddefinitions") defs = 0;
      else if (tok == "$comment")
        do void'($fscanf(fd, "%s", tok)); while (tok != "$end");
      else if (!defs && tok.substr(0, 0) == "#" && tok.len() > 1) begin
        tok = tok.substr(1, tok.len() - 1);
        t = tok.atoi();
      end else if (!defs && tok.len() >= 2 && (tok[0] == "0" || tok[0] == "1"))
        line = {line, $sformatf(" #%0d=%c", t, tok[0])};
    end
    $fclose(fd);
    $display("%s", line);
  endtask

  initial begin
    $dumpports(ua, fname_a);
    $dumpports(ub, fname_b);
    $dumpfile("test_evcd_dumpports_files_defaults_and_control_scope_vars.vcd");
    $dumpvars(0, test_evcd_dumpports_files_defaults_and_control_scope.vp);
    #10 vp = 1'b1; vr = 1'b1; vs = 1'b1; ud.tv = 1'b1;
    #10 $dumpportsoff;
    #5 vp = 1'b0; vr = 1'b0; vs = 1'b0; ud.tv = 1'b0;
    #5 $dumpportson();
    #10 $dumpportsall;
    #5 vp = 1'b1;
    #5 $dumpportsall(fname_b);
    #2 $dumpportsoff(fname_b);
    #3 vr = 1'b1; vs = 1'b1; ud.tv = 1'b1;
    #5 $dumpportsall(fname_a);
    #2 $dumpportson(fname_b);
    #3 $dumpportsflush(fname_b);
    #5 $dumpportsflush;
    $dumpflush;
    read_ports("a", fname_a);
    read_ports("b", "test_evcd_dumpports_files_defaults_and_control_scope_b.evcd");
    read_ports("c (dumpports.vcd)", "dumpports.vcd");
    read_ports("d", "test_evcd_dumpports_files_defaults_and_control_scope_d.evcd");
    read_vars("test_evcd_dumpports_files_defaults_and_control_scope_vars.vcd");
  end
endmodule
