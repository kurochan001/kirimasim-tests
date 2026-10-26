/*
:name: test_vcd_unpacked_struct_and_undumped
:description: An unpacked structure appears as a named fork-join scope whose member variables have the types of their declarations, while an unpacked array and an automatic variable are not dumped (IEEE 1800-2023 Section 21.7.5)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.5 21.7.2.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vcd_unpacked_struct_and_undumped.expected
*/
// IEEE 1800-2023 §21.7.5: an unpacked structure appears in the VCD file as
// a named fork-join block, and its members appear with the types that Table
// 21-11 gives for their declarations; an unpacked array and an automatic
// variable are not dumped. §21.7.2.3: $scope names a scope, here the fork
// block, and $var declares a variable of it.
//
// The structure pair has two logic [3:0] members, so the file has a $scope
// fork pair and, inside it, $var reg 4 declarations named hi and lo. The
// unpacked array arr and the automatic variable auto_var of the active task
// must not be declared anywhere in the file.

`timescale 1ns/1ns

module vcd_struct_child;
  logic child_bit = 1'b1;
endmodule

module test_vcd_unpacked_struct_and_undumped;
  typedef struct {
    logic [3:0] hi;
    logic [3:0] lo;
  } pair_t;

  pair_t pair_value;
  logic [1:0] arr[0:2];
  vcd_struct_child u();

  task automatic hold_value();
    int auto_var = 7;
    #2;
  endtask

  task automatic read_dump();
    int fd, size;
    string token, kind, code, reference;
    string pending_scope, scope_kind;
    bit pair_scope = 0, hi_ok = 0, lo_ok = 0;
    bit array_seen = 0, automatic_seen = 0, child_seen = 0;
    int depth = 0;

    fd = $fopen("struct.vcd", "r");
    if (fd == 0) $fatal(1, "the dump file is missing");
    while ($fscanf(fd, "%s", token) == 1) begin
      if (token == "$scope") begin
        void'($fscanf(fd, "%s %s", scope_kind, reference));
        depth++;
        if (scope_kind == "fork" && reference == "pair_value") pair_scope = 1;
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
      end else if (token == "$upscope") begin
        depth--;
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
      end else if (token == "$var") begin
        void'($fscanf(fd, "%s %d %s %s", kind, size, code, reference));
        if (reference == "hi" && kind == "reg" && size == 4) hi_ok = 1;
        if (reference == "lo" && kind == "reg" && size == 4) lo_ok = 1;
        if (reference == "arr") array_seen = 1;
        if (reference == "auto_var") automatic_seen = 1;
        if (reference == "child_bit") child_seen = 1;
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
      end else if (token == "$comment" || token == "$date" || token == "$version" ||
                   token == "$timescale" || token == "$enddefinitions") begin
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
      end else if (token == "$dumpvars" || token == "$dumpoff" ||
                   token == "$dumpon" || token == "$dumpall" || token == "$end") begin
      end else if (token[0] == "#" || token[0] == "b" || token[0] == "B" ||
                   token[0] == "r" || token[0] == "R") begin
      end
    end
    $fclose(fd);
    $display("the structure is a named fork scope: %0d", pair_scope);
    $display("the members are reg 4: %0d", hi_ok && lo_ok);
    $display("the unpacked array is not dumped: %0d", !array_seen);
    $display("the automatic variable is not dumped: %0d", !automatic_seen);
    $display("the instance below the module is dumped: %0d", child_seen);
  endtask

  initial begin
    pair_value.hi = 4'hA;
    pair_value.lo = 4'h5;
    arr[0] = 2'b01;
    arr[1] = 2'b10;
    arr[2] = 2'b11;
    $dumpfile("struct.vcd");
    $dumpvars(0, test_vcd_unpacked_struct_and_undumped);
    fork
      hold_value();
    join_none
    #1 $dumpflush;
    read_dump();
  end
endmodule
