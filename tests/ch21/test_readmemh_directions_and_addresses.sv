/*
:name: test_readmemh_directions_and_addresses
:description: $readmemh loads upward from the lowest address or from a start address, toward the finish address when both are given, downward when the start is the higher one, and keeps that direction after @ addresses of either case in the file; the file name can be a literal, a string or an integral variable, and the task can run at any time (IEEE 1800-2023 Section 21.4)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_readmemh_directions_and_addresses.expected
*/
// IEEE 1800-2023 §21.4: without addresses in the task, loading starts at the
// lowest address of the memory; with only a start address it starts there;
// both go upward, also after an address in the file. With a start and a finish
// address loading goes from the start toward the finish, downward if the start
// is greater, and keeps that direction after an address in the file, which has
// to lie in that range. An address in the file is @ followed at once by
// hexadecimal digits in either case, and the file can hold several. The file
// name is a string literal, a string or an integral variable holding the
// characters. The tasks can be called at any time: the last load runs at time
// 5. Each line shows the 16 words, which are set to ee before each load. The
// files are created in the current directory. The 5.052 release of Verilator
// loads upward from the start address 11, and from the address 8.

`timescale 1ns/1ns

module test_readmemh_directions_and_addresses;
  logic [7:0] mem [0:15];
  string name_s;
  logic [8*12-1:0] name_i;
  int fd;

  task automatic show(string what);
    string line = "";
    foreach (mem[i]) line = {line, $sformatf(" %h", mem[i])};
    $display("%s:%s", what, line);
    foreach (mem[i]) mem[i] = 8'hee;
  endtask

  task automatic put(string name, string text);
    int f = $fopen(name, "w");
    $fdisplay(f, "%s", text);
    $fclose(f);
  endtask

  initial begin
    foreach (mem[i]) mem[i] = 8'hee;
    put("rm_dir1.mem", "a1 a2 @A b1 @c c1 c2");
    put("rm_dir2.mem", "d1 d2 @9 d3 d4");
    put("rm_dir3.mem", "e1 e2 @8 e3 e4");
    put("rm_dir4.mem", "f1 @5 f2 f3");

    $readmemh("rm_dir1.mem", mem);
    show("no addresses");
    name_s = "rm_dir2.mem";
    $readmemh(name_s, mem, 4);
    show("start 4");
    name_i = "rm_dir4.mem";
    $readmemh(name_i, mem, 2, 7);
    show("start 2 finish 7");
    #5;
    $readmemh("rm_dir3.mem", mem, 11, 6);
    show($sformatf("start 11 finish 6 at %0t", $time));
  end
endmodule
