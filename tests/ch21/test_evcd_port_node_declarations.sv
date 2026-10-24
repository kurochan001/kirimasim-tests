/*
:name: test_evcd_port_node_declarations
:description: The extended VCD file of $dumpports starts with the date, version and timescale, then gives one $scope of type module with a $var port entry for each port of the selected module, of size 1 or its declared [msb:lsb] index, with the codes <0, <1, ... in the order of the module declaration, a separate entry for each part of a concatenated port, and no entry for the ports of the instances below it (IEEE 1800-2023 Sections 21.7.4.1 and 21.7.4.2)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.4.1 21.7.4.2 21.7.3.1 21.7.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_evcd_port_node_declarations.expected
*/
// IEEE 1800-2023 §21.7.3.1: $dumpports dumps the ports of the module that
// its scope list names, which are taken as the primary I/O pins; the ports
// of the instances below it are not dumped. §21.7.4.1: the file starts
// with the date (day, month, date, time and year), the version and the
// timescale (1, 10 or 100 and s, ms, us, ns, ps or fs), then the scope of
// the ports, of the type module, and then the value changes. §21.7.4.2: the
// node information has one $var per port, of the type port, whose size is
// 1 for a scalar and the index of the port declaration, [msb:lsb], for a
// vector, and whose identifier code is an integer preceded by <, starting
// at 0 and increasing by 1 for each port in the order of the module
// declaration; at least one space separates the elements, and the parts of
// a concatenated port are separate entries. evcd_node_dut has the
// non-ANSI ports a, d [0:3], the concatenation {ca, cb} and y, and an
// instance of evcd_node_leaf, which has ports of its own. The test calls
// $dumpportsflush and reads the file token by token up to $enddefinitions,
// white space separating them (§21.7.4). It prints which header sections
// come before the first scope, the number of fields of the date, the
// timescale, whether every scope is of type module, each $var in the order
// of the file, and the number of tokens outside the expected syntax. It
// does not print the text of the date and version, the scope name or the
// number of scopes, which the tool chooses.
// No release of Icarus Verilog 13.0 or Verilator 5.052 implements
// $dumpports, so the expected output comes from the clauses alone.

`timescale 1ns / 1ns

module evcd_node_leaf(input wire li, output wire lo);
  assign lo = ~li;
endmodule

module evcd_node_dut(a, d, {ca, cb}, y);
  input a;
  input [0:3] d;
  input ca, cb;
  output y;
  wire inner;
  evcd_node_leaf leaf(.li(a), .lo(inner));
  assign y = inner ^ ca ^ cb ^ d[0];
endmodule

module test_evcd_port_node_declarations;
  localparam string FILE = "test_evcd_port_node_declarations.evcd";
  logic a = 1'b0, ca = 1'b1, cb = 1'b0;
  logic [0:3] d = 4'b1010;
  wire y;

  evcd_node_dut dut(a, d, {ca, cb}, y);

  task automatic read(string file);
    int fd, date_fields = 0, bad = 0;
    string tok, typ, size, code, ref_name, scale = "";
    bit defs = 0, date_seen = 0, version_seen = 0, scale_seen = 0, other_scope = 0;
    fd = $fopen(file, "r");
    while ($fscanf(fd, "%s", tok) == 1 && tok != "$enddefinitions") begin
      if (tok == "$date") begin
        if (!defs) date_seen = 1;
        void'($fscanf(fd, "%s", tok));
        while (tok != "$end") begin
          date_fields++;
          void'($fscanf(fd, "%s", tok));
        end
      end else if (tok == "$version") begin
        if (!defs) version_seen = 1;
        do void'($fscanf(fd, "%s", tok)); while (tok != "$end");
      end else if (tok == "$timescale") begin
        if (!defs) scale_seen = 1;
        void'($fscanf(fd, "%s", tok));
        while (tok != "$end") begin
          scale = {scale, tok};
          void'($fscanf(fd, "%s", tok));
        end
      end else if (tok == "$scope") begin
        if (!defs)
          $display("before the first scope: $date %0s, $version %0s, $timescale %0s",
                   date_seen ? "yes" : "no", version_seen ? "yes" : "no",
                   scale_seen ? "yes" : "no");
        defs = 1;
        void'($fscanf(fd, "%s", typ));
        if (typ != "module") other_scope = 1;
        do void'($fscanf(fd, "%s", tok)); while (tok != "$end");
      end else if (tok == "$var") begin
        void'($fscanf(fd, "%s %s", typ, size));
        while (size.substr(0, 0) == "[" && size.substr(size.len() - 1, size.len() - 1) != "]")
          if ($fscanf(fd, "%s", tok) == 1) size = {size, tok};
        void'($fscanf(fd, "%s %s", code, ref_name));
        $display("var %0s %0s %0s %0s", typ, size, code, ref_name);
        void'($fscanf(fd, "%s", tok));
        if (tok != "$end") bad++;
        while (tok != "$end") void'($fscanf(fd, "%s", tok));
      end else if (tok == "$upscope" || tok == "$comment") begin
        do void'($fscanf(fd, "%s", tok)); while (tok != "$end");
      end else begin
        bad++;
      end
    end
    $fclose(fd);
    $display("date fields: %0d", date_fields);
    $display("timescale: %0s", scale);
    $display("every scope of type module: %0s", defs && !other_scope ? "yes" : "no");
    $display("tokens outside the declaration syntax: %0d", bad);
  endtask

  initial begin
    $dumpports(test_evcd_port_node_declarations.dut, FILE);
    #5 a = 1'b1;
    #5 $dumpportsflush(FILE);
    read(FILE);
  end
endmodule
