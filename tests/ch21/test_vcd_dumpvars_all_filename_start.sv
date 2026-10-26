/*
:name: test_vcd_dumpvars_all_filename_start
:description: $dumpfile accepts an integral variable that holds a character string, $dumpvars without arguments dumps every variable of the model including those of the instances below it, and dumping starts at the end of the time unit in which $dumpvars is called (IEEE 1800-2023 Sections 21.7.1.1, 21.7.1.2 and 21.7.1.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.1.1 21.7.1.2 21.7.1.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vcd_dumpvars_all_filename_start.expected
*/
// IEEE 1800-2023 §21.7.1.1: the file name of $dumpfile may be a string
// literal, a string expression or an integral value that holds a character
// string. §21.7.1.2: $dumpvars called without arguments selects every
// variable in the model, including those of the instances below the calling
// module. §21.7.1.3: $dumpvars starts dumping at the end of its current
// simulation time unit, so a nonblocking update scheduled in that time unit
// is what the file records.
//
// The file name is the 8-character integral variable name_hold. At time 5
// the test makes the nonblocking a <= 1, changes v at once, and calls
// $dumpvars; read back, the entry for time 5 has a = 1, and the declaration
// of cbit, a variable of the child instance, shows that every variable was
// selected.

`timescale 1ns/1ns

module dump_child;
  logic cbit = 1'b1;
endmodule

module test_vcd_dumpvars_all_filename_start;
  logic a = 1'b0;
  logic [3:0] v = 4'h3;
  bit [8*8-1:0] name_hold = "ints.vcd";
  dump_child u();
  string names[0:15];
  string code_list[0:15];
  int vcount = 0;

  function automatic int find_var(string code);
    for (int i = 0; i < vcount; i++)
      if (code_list[i] == code) return i;
    return -1;
  endfunction

  task automatic read_dump();
    int fd, size, time_now = -1, time_a = -1, a_changes = 0;
    bit child_seen = 0, a_value = 0, opened = 0, a_zero = 0;
    string token, kind, code, reference, digits;

    fd = $fopen("ints.vcd", "r");
    if (fd != 0) opened = 1;
    while (fd != 0 && $fscanf(fd, "%s", token) == 1) begin
      if (token == "$var") begin
        void'($fscanf(fd, "%s %d %s %s", kind, size, code, reference));
        if (reference == "cbit") child_seen = 1;
        names[vcount] = reference;
        code_list[vcount] = code;
        vcount++;
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
      end else if (token == "$comment" || token == "$date" || token == "$version" ||
                   token == "$timescale" || token == "$scope" || token == "$upscope" ||
                   token == "$enddefinitions") begin
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
      end else if (token == "$dumpvars" || token == "$dumpoff" ||
                   token == "$dumpon" || token == "$dumpall" || token == "$end") begin
      end else if (token[0] == "#") begin
        digits = token.substr(1, token.len() - 1);
        time_now = digits.atoi();
      end else if (token[0] == "b" || token[0] == "B") begin
        void'($fscanf(fd, "%s", code));
      end else if (token[0] == "0" || token[0] == "1" ||
                   token[0] == "x" || token[0] == "X" ||
                   token[0] == "z" || token[0] == "Z") begin
        code = token.substr(1, token.len() - 1);
        if (find_var(code) >= 0) begin
          reference = names[find_var(code)];
          if (reference == "a" && time_now == 5) begin
            time_a = time_now;
            a_changes++;
            if (token[0] == "1") a_value = 1;
            if (token[0] == "0") a_zero = 1;
          end
        end
      end else if (token[0] == "r" || token[0] == "R") begin
        void'($fscanf(fd, "%s", code));
      end
    end
    if (fd != 0) $fclose(fd);
    $display("the integral variable names the file: %0d", opened);
    $display("the child instance is dumped: %0d", child_seen);
    $display("a is already 1 in the time unit of the call: %0d",
             time_a == 5 && a_value && !a_zero && a_changes == 1);
  endtask

  initial begin
    $dumpfile(name_hold);
    #5;
    a <= 1'b1;
    v = 4'hC;
    $dumpvars;
    #5 $dumpflush;
    read_dump();
  end
endmodule
