/*
:name: test_vcd_dumpvars_no_arguments
:description: $dumpvars with no arguments dumps every variable in the model, of the top module and of the instances below it (IEEE 1800-2023 Section 21.7.1.2)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.1.2 21.7.2.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vcd_dumpvars_no_arguments.expected
*/
// IEEE 1800-2023 §21.7.1.2: $dumpvars invoked with no arguments dumps all the
// variables in the model to the VCD file. The test has a 4-bit vector and an
// int in the top module and an 8-bit vector and a bit in an instance, calls
// $dumpvars with no arguments, and reads the $var sections of the file back.
// All four variables are there with their types and sizes (§21.7.2.3), and
// no other variable is, because the reader is an automatic task and its
// automatic variables are not dumped (§21.7.5). §21.7.2.1, Syntax 21-20,
// makes the index range of a reference optional: the test accepts a plain
// identifier or the declared [msb:lsb] range, but a range that is written
// has to be the one of the declaration.

`timescale 1ns/1ns

module vdna_child;
  logic [7:0] cv = 8'h12;
  logic cs = 1'b1;
endmodule

module vdna_reader;
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
    string tok, typ, code, nm, rng, whose;
    string n_tv = "", n_ti = "", n_cv = "", n_cs = "";
    bit after = 1'b0;
    int nvars = 0;
    while ($fscanf(fd, "%s", tok) == 1) begin
      if (!after) begin
        if (tok == "$enddefinitions") begin
          do void'($fscanf(fd, "%s", tok)); while (tok != "$end");
          after = 1'b1;
        end else if (tok == "$scope") begin
          void'($fscanf(fd, "%s %s", typ, whose));
          do void'($fscanf(fd, "%s", tok)); while (tok != "$end");
        end else if (tok == "$upscope") begin
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
          if (nm == "tv") n_tv = var_state(typ, "reg", sz, 4, rng, "3:0");
          if (nm == "ti") n_ti = var_state(typ, "integer", sz, 32, rng, "31:0");
          if (nm == "cv") n_cv = var_state(typ, "reg", sz, 8, rng, "7:0");
          if (nm == "cs") n_cs = var_state(typ, "reg", sz, 1, rng, "-");
        end else begin
          do void'($fscanf(fd, "%s", tok)); while (tok != "$end");
        end
      end
    end
    $fclose(fd);
    $display("vars: %0d", nvars);
    if (n_tv == "") n_tv = "missing";
    if (n_ti == "") n_ti = "missing";
    if (n_cv == "") n_cv = "missing";
    if (n_cs == "") n_cs = "missing";
    $display("tv %s", n_tv);
    $display("ti %s", n_ti);
    $display("cv %s", n_cv);
    $display("cs %s", n_cs);
  endtask
endmodule

module test_vcd_dumpvars_no_arguments;
  logic [3:0] tv = 4'h3;
  int ti = 7;
  vdna_child u();
  vdna_reader r();

  initial begin
    $dumpfile("test_vcd_dumpvars_no_arguments.vcd");
    $dumpvars;
    #5 tv = 4'hc;
    #1 $dumpflush;
    r.read_and_report("test_vcd_dumpvars_no_arguments.vcd");
  end
endmodule
