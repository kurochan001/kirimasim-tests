/*
:name: test_vcd_filename_string_and_depth_zero
:description: $dumpfile accepts a string expression and $dumpvars with depth 0 dumps a selected instance with all instances below it while a selected variable stays alone (IEEE 1800-2023 Sections 21.7.1.1 and 21.7.1.2)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.1.1 21.7.1.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vcd_filename_string_and_depth_zero.expected
*/
// IEEE 1800-2023 §21.7.1.1: the name of the dump file may be a string
// expression; the test builds it by concatenating a variable and a literal.
// §21.7.1.2: a depth of 0 dumps all variables of each selected module
// instance and of every instance below it, but the depth does not apply to
// a selected variable. The test selects the instance mid, whose variable and
// the variable of its instance lf appear, and the single variable
// other.of.lv, while the variables of this module and other.ov stay out.

`timescale 1ns/1ns

module depth_zero_leaf;
  logic [3:0] lv = 4'h5;
endmodule

module depth_zero_mid;
  logic [3:0] mv = 4'h6;
  depth_zero_leaf lf();
endmodule

module depth_zero_other;
  logic [3:0] ov = 4'h9;
  depth_zero_leaf of();
endmodule

module test_vcd_filename_string_and_depth_zero;
  logic [3:0] top_value = 4'h7;
  depth_zero_mid mid();
  depth_zero_other other();
  string base = "depth";

  task automatic read_dump();
    int fd, size;
    string token, kind, code, reference, path = "";
    string scopes[$];
    bit seen_mv = 0, seen_mid_lv = 0, seen_of_lv = 0, seen_top = 0, seen_ov = 0;

    fd = $fopen({base, "_zero.vcd"}, "r");
    if (fd == 0) $fatal(1, "the string expression did not name the file");
    while ($fscanf(fd, "%s", token) == 1) begin
      if (token == "$scope") begin
        void'($fscanf(fd, "%s %s", kind, reference));
        scopes.push_back(reference);
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
      end else if (token == "$upscope") begin
        void'($fscanf(fd, "%s", token));
        void'(scopes.pop_back());
      end else if (token == "$var") begin
        void'($fscanf(fd, "%s %d %s %s", kind, size, code, reference));
        path = "";
        foreach (scopes[i]) path = {path, scopes[i], "."};
        path = {path, reference};
        if (path == "test_vcd_filename_string_and_depth_zero.mid.mv") seen_mv = 1;
        if (path == "test_vcd_filename_string_and_depth_zero.mid.lf.lv") seen_mid_lv = 1;
        if (path == "test_vcd_filename_string_and_depth_zero.other.of.lv") seen_of_lv = 1;
        if (path == "test_vcd_filename_string_and_depth_zero.top_value") seen_top = 1;
        if (path == "test_vcd_filename_string_and_depth_zero.other.ov") seen_ov = 1;
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
      end else if (token == "$date" || token == "$version" || token == "$timescale" ||
                   token == "$comment") begin
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
      end
    end
    $fclose(fd);
    $display("the depth-zero instance is dumped: %0d", seen_mv && seen_mid_lv);
    $display("the variable below it is dumped alone: %0d", seen_of_lv);
    $display("unselected variables stay out: %0d", !seen_top && !seen_ov);
  endtask

  initial begin
    $dumpfile({base, "_zero.vcd"});
    $dumpvars(0, mid);
    $dumpvars(0, other.of.lv);
    #1 $dumpflush;
    read_dump();
  end
endmodule
