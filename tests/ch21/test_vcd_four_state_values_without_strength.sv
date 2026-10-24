/*
:name: test_vcd_four_state_values_without_strength
:description: A 4-state VCD file records the changes of nets as 0, 1, x and z without strength information, so nets driven with strong, weak, pull and supply strength give the same scalar value changes (IEEE 1800-2023 Sections 21.7 and 21.7.2.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7 21.7.2.1 21.7.2 21.7.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_vcd_four_state_values_without_strength.expected
*/
// IEEE 1800-2023 §21.7: a 4-state VCD file represents changes in 0, 1, x
// and z with no strength information, while the extended VCD file of
// $dumpports also holds strengths (21.7.3). §21.7.1: $dumpfile and
// $dumpvars in the source create the file, which holds the definitions of
// the dumped variables and their value changes; §21.7.2: white space
// separates its commands. §21.7.2.1: the value changes of
// variables other than real are given in binary by 0, 1, x or z, and
// strength information is not dumped; a scalar change is the value
// followed by the identifier code. The variable v drives four nets through
// continuous assignments of strong, weak, pull and supply strength, and
// takes the values 0, 1, x and z at 0, 10, 20 and 30 ns. The test dumps
// the four nets, reads the file token by token and prints their values at
// each time, sorted by name, and the number of tokens of the simulation
// commands that are neither a keyword, a #time nor a scalar change of one
// character 0, 1, x or z followed by a defined identifier code; a value
// with strength would be counted there.

`timescale 1ns / 1ns

module test_vcd_four_state_values_without_strength;
  logic v = 1'b0;
  wire w_s, w_w, w_p, w_y;
  string names[$], codes[$], vals[$];

  assign w_s = v;
  assign (weak0, weak1) w_w = v;
  assign (pull0, pull1) w_p = v;
  assign (supply0, supply1) w_y = v;

  function automatic int find(string code);
    foreach (codes[k]) if (codes[k] == code) return k;
    return -1;
  endfunction

  task automatic flush(int t, string section);
    string line, tmp;
    bit any = 0;
    line = $sformatf("#%0d", t);
    if (section != "") line = {line, " ", section};
    line = {line, ":"};
    foreach (names[k])
      if (vals[k] != "") begin
        line = {line, " ", names[k], "=", vals[k]};
        vals[k] = "";
        any = 1;
      end
    if (any) $display("%s", line);
  endtask

  task automatic read(string file);
    int fd, k, t = 0, bad = 0;
    string tok, typ, size, code, ref_name, rest, section = "", tmp;
    bit defs = 1;
    fd = $fopen(file, "r");
    while ($fscanf(fd, "%s", tok) == 1) begin
      if (tok == "$var") begin
        void'($fscanf(fd, "%s %s %s %s", typ, size, code, ref_name));
        do void'($fscanf(fd, "%s", tmp)); while (tmp != "$end");
        // Keeps the variables sorted by name.
        k = 0;
        while (k < names.size() && names[k] < ref_name) k++;
        names.insert(k, ref_name);
        codes.insert(k, code);
        vals.insert(k, "");
      end else if (tok == "$enddefinitions") begin
        defs = 0;
        do void'($fscanf(fd, "%s", tok)); while (tok != "$end");
      end else if (tok == "$date" || tok == "$version" || tok == "$timescale" ||
                   tok == "$scope" || tok == "$upscope" || tok == "$comment") begin
        do void'($fscanf(fd, "%s", tok)); while (tok != "$end");
      end else if (defs) begin
        bad++;
      end else if (tok.substr(0, 0) == "#" && tok.len() > 1) begin
        flush(t, section);
        rest = tok.substr(1, tok.len() - 1);
        t = rest.atoi();
      end else if (tok == "$dumpvars" || tok == "$dumpall" || tok == "$dumpon" ||
                   tok == "$dumpoff") begin
        flush(t, section);
        section = tok;
      end else if (tok == "$end") begin
        flush(t, section);
        section = "";
      end else begin
        rest = tok.substr(1, tok.len() - 1);
        k = find(rest);
        if (k >= 0 && (tok[0] == "0" || tok[0] == "1" || tok[0] == "x" || tok[0] == "X" ||
                       tok[0] == "z" || tok[0] == "Z")) begin
          if (tok[0] == "X") vals[k] = "x";
          else if (tok[0] == "Z") vals[k] = "z";
          else vals[k] = tok.substr(0, 0);
        end else begin
          bad++;
        end
      end
    end
    flush(t, section);
    $fclose(fd);
    $display("tokens that are not a command, a time or a value change without strength: %0d",
             bad);
  endtask

  initial begin
    $dumpfile("test_vcd_four_state_values_without_strength.vcd");
    $dumpvars(0, test_vcd_four_state_values_without_strength.w_s,
              test_vcd_four_state_values_without_strength.w_w,
              test_vcd_four_state_values_without_strength.w_p,
              test_vcd_four_state_values_without_strength.w_y);
    #10 v = 1'b1;
    #10 v = 1'bx;
    #10 v = 1'bz;
    #10 $dumpflush;
    read("test_vcd_four_state_values_without_strength.vcd");
  end
endmodule
