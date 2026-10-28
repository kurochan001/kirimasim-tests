/*
:name: test_vcd_dumpvars_selection_forms
:description: $dumpvars takes a level and then modules or variables, level 1 dumps only the named instance, level 0 also dumps the instances below it, and an instance of its own is a selection (IEEE 1800-2023 Section 21.7.1.2)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.1.2 21.7.2.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vcd_dumpvars_selection_forms.expected
*/
// IEEE 1800-2023 §21.7.1.2: the first argument of $dumpvars is the number of
// levels below each named module instance to dump, and the arguments after it
// name module instances or individual variables. The test names two sibling
// instances: $dumpvars(1, i1) dumps the variable of i1 but not the one in the
// instance below it, and $dumpvars(0, i2) dumps the variable of i2 and the one
// in the instance below it. Both calls are at the same simulation time, as the
// clause requires. The reader prints the type and size of what the $var
// sections of the file name (§21.7.2.3), so the variable below i1 must be
// missing. §21.7.2.1, Syntax 21-20, makes the index range of a reference
// optional: the test accepts a plain identifier or the declared [msb:lsb]
// range, but a range that is written has to be the one of the declaration.

`timescale 1ns/1ns

module vds_grand;
  logic [3:0] gv = 4'h9;
endmodule

module vds_c1;
  logic a1 = 1'b1;
  vds_grand gg();
endmodule

module vds_c2;
  logic a2 = 1'b0;
  vds_grand gg();
endmodule

module vds_reader;
  // The state of one $var declaration: its type and size as §21.7.2.3
  // requires them, and an index range that is either absent or the one of
  // the declaration.
  function automatic string var_state(string typ, string want_typ, int size,
                                      int want_size, string rng,
                                      string want_rng);
    if (typ != want_typ)
      return $sformatf("%s %0d: type, want %s", typ, size, want_typ);
    if (size != want_size)
      return $sformatf("%s %0d: size, want %0d", typ, size, want_size);
    if (rng != "-" && rng != want_rng)
      return $sformatf("%s %0d: range %s, want %s or none",
                       typ, size, rng, want_rng);
    return $sformatf("%s %0d ok", typ, size);
  endfunction

  // The range of a reference may be a token of its own (tv [3:0]) or part
  // of the reference (tv[3:0]), so a reference can hold the bracket.
  function automatic int bracket_at(string s);
    for (int i = 0; i < s.len(); i++)
      if (s[i] == "[") return i;
    return -1;
  endfunction

  task automatic read_and_report(string file);
    int fd = $fopen(file, "r");
    int sz, bracket;
    string tok, typ, code, nm, rng, full;
    string s1 = "", s2 = "", s3 = "";
    string n_a1 = "", n_a2 = "", n_g2 = "", n_g1 = "";
    bit after = 1'b0;
    int depth = 0;
    int nvars = 0;
    while ($fscanf(fd, "%s", tok) == 1) begin
      if (!after) begin
        if (tok == "$enddefinitions") begin
          do void'($fscanf(fd, "%s", tok)); while (tok != "$end");
          after = 1'b1;
        end else if (tok == "$scope") begin
          void'($fscanf(fd, "%s %s", typ, nm));
          depth++;
          if (depth == 1) s1 = nm;
          else if (depth == 2) s2 = nm;
          else s3 = nm;
          do void'($fscanf(fd, "%s", tok)); while (tok != "$end");
        end else if (tok == "$upscope") begin
          depth--;
          do void'($fscanf(fd, "%s", tok)); while (tok != "$end");
        end else if (tok == "$var") begin
          void'($fscanf(fd, "%s %d %s %s", typ, sz, code, nm));
          rng = "-";
          bracket = bracket_at(nm);
          if (bracket >= 0) begin
            rng = nm.substr(bracket + 1, nm.len() - 2);
            nm = nm.substr(0, bracket - 1);
            void'($fscanf(fd, "%s", tok));
          end else begin
            void'($fscanf(fd, "%s", tok));
            if (tok != "$end") begin
              rng = tok.substr(1, tok.len() - 2);
              void'($fscanf(fd, "%s", tok));
            end
          end
          nvars++;
          full = s1;
          if (depth >= 2) full = {full, ".", s2};
          if (depth >= 3) full = {full, ".", s3};
          full = {full, ".", nm};
          if (full == "test_vcd_dumpvars_selection_forms.i1.a1")
            n_a1 = var_state(typ, "reg", sz, 1, rng, "-");
          if (full == "test_vcd_dumpvars_selection_forms.i2.a2")
            n_a2 = var_state(typ, "reg", sz, 1, rng, "-");
          if (full == "test_vcd_dumpvars_selection_forms.i2.gg.gv")
            n_g2 = var_state(typ, "reg", sz, 4, rng, "3:0");
          if (full == "test_vcd_dumpvars_selection_forms.i1.gg.gv")
            n_g1 = var_state(typ, "reg", sz, 4, rng, "3:0");
        end else begin
          do void'($fscanf(fd, "%s", tok)); while (tok != "$end");
        end
      end
    end
    $fclose(fd);
    if (n_a1 == "") n_a1 = "missing";
    if (n_a2 == "") n_a2 = "missing";
    if (n_g2 == "") n_g2 = "missing";
    if (n_g1 == "") n_g1 = "missing";
    $display("vars: %0d", nvars);
    $display("i1.a1 %s", n_a1);
    $display("i1.gg.gv %s", n_g1);
    $display("i2.a2 %s", n_a2);
    $display("i2.gg.gv %s", n_g2);
  endtask
endmodule

module test_vcd_dumpvars_selection_forms;
  vds_c1 i1();
  vds_c2 i2();
  vds_reader r();

  initial begin
    $dumpfile("test_vcd_dumpvars_selection_forms.vcd");
    $dumpvars(1, test_vcd_dumpvars_selection_forms.i1);
    $dumpvars(0, test_vcd_dumpvars_selection_forms.i2);
    #5 i1.gg.gv = 4'h3;
    #1 $dumpflush;
    r.read_and_report("test_vcd_dumpvars_selection_forms.vcd");
  end
endmodule
