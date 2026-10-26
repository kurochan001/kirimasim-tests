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
// All four variables are there with their sizes and index ranges
// (§21.7.2.3) and no other variable is, because the reader is an automatic
// task and its automatic variables are not dumped (§21.7.5).

`timescale 1ns/1ns

module vdna_child;
  logic [7:0] cv = 8'h12;
  logic cs = 1'b1;
endmodule

module vdna_reader;
  task automatic read_and_report(string file);
    int fd = $fopen(file, "r");
    string tok, typ, size, code, nm, rng, whose;
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
          void'($fscanf(fd, "%s %s %s %s", typ, size, code, nm));
          rng = "-";
          void'($fscanf(fd, "%s", tok));
          if (tok != "$end") begin
            rng = tok.substr(1, tok.len() - 2);
            void'($fscanf(fd, "%s", tok));
          end
          nvars++;
          if (nm == "tv") n_tv = {size, " ", rng};
          if (nm == "ti") n_ti = {size, " ", rng};
          if (nm == "cv") n_cv = {size, " ", rng};
          if (nm == "cs") n_cs = {size, " ", rng};
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
