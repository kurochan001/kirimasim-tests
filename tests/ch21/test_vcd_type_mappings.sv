/*
:name: test_vcd_type_mappings
:description: The VCD var declarations map bit logic byte shortint longint int enum and shortreal to the IEEE 1364-2005 types, collapse packed arrays and structures into one reg vector, map uwire to wire, and leave unpacked arrays out (IEEE 1800-2023 Sections 21.7.2.3 and 21.7.5)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.2.3 21.7.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vcd_type_mappings.expected
*/
// IEEE 1800-2023 §21.7.5: bit and logic are reg with the total size of their
// packed dimension, byte is reg 8, shortint reg 16, longint reg 64, int
// integer 32, an untyped enum integer 32 and a typed enum the declared type,
// shortreal is real, packed arrays and structures are one reg vector with
// their dimensions collapsed, and unpacked arrays are not dumped. §21.7.2.3:
// a uwire net has the var type wire. The test dumps one variable of each
// type and prints the type and size of every declaration that it checks.

`timescale 1ns/1ns

module type_mapping_child;
  logic [3:0] unwire_value;
endmodule

module test_vcd_type_mappings;
  bit b1 = 1'b1;
  bit [3:0] b4 = 4'h9;
  logic [7:0] l8 = 8'h5a;
  byte by = 8'ha5;
  shortint si = 16'h1234;
  longint li = 64'h1234_5678_9abc_def0;
  int iv = -5;
  typedef enum {AA, BB} de_t;
  de_t de = BB;
  typedef enum byte {X1 = 1, X2 = 2} se_t;
  se_t se = X2;
  typedef enum logic [7:0] {Y1 = 3, Y2 = 4} le_t;
  le_t le = Y2;
  real r = 0.5;
  shortreal sr = 0.25;
  typedef struct packed {
    logic [3:0] hi;
    logic [3:0] lo;
  } packed_struct_t;
  packed_struct_t ps = 8'ha5;
  logic [1:0][3:0] pa = 8'h3c;
  logic [1:0] mem[0:1];
  uwire uw;
  assign uw = b1;

  function automatic bit is_1364_type(string text);
    return text == "event" || text == "integer" || text == "parameter" ||
           text == "real" || text == "realtime" || text == "reg" ||
           text == "supply0" || text == "supply1" || text == "time" ||
           text == "tri" || text == "triand" || text == "trior" ||
           text == "trireg" || text == "tri0" || text == "tri1" ||
           text == "wand" || text == "wire" || text == "wor";
  endfunction

  task automatic read_dump();
    int fd, size;
    string token, kind, code, reference;
    bit array_seen = 0, extension_seen = 0;
    bit b1_ok = 0, b4_ok = 0, l8_ok = 0, by_ok = 0, si_ok = 0, li_ok = 0;
    bit iv_ok = 0, de_ok = 0, se_ok = 0, le_ok = 0, sr_ok = 0;
    bit ps_ok = 0, pa_ok = 0, uw_ok = 0;

    fd = $fopen("types.vcd", "r");
    if (fd == 0) $fatal(1, "the dump file is missing");
    while ($fscanf(fd, "%s", token) == 1) begin
      if (token == "$var") begin
        void'($fscanf(fd, "%s %d %s %s", kind, size, code, reference));
        if (reference == "b1") b1_ok = (kind == "reg" && size == 1);
        if (reference == "b4") b4_ok = (kind == "reg" && size == 4);
        if (reference == "l8") l8_ok = (kind == "reg" && size == 8);
        if (reference == "by") by_ok = (kind == "reg" && size == 8);
        if (reference == "si") si_ok = (kind == "reg" && size == 16);
        if (reference == "li") li_ok = (kind == "reg" && size == 64);
        if (reference == "iv") iv_ok = (kind == "integer" && size == 32);
        if (reference == "de") de_ok = (kind == "integer" && size == 32);
        if (reference == "se") se_ok = (kind == "reg" && size == 8);
        if (reference == "le") le_ok = (kind == "reg" && size == 8);
        if (reference == "sr") sr_ok = (kind == "real");
        if (reference == "ps") ps_ok = (kind == "reg" && size == 8);
        if (reference == "pa") pa_ok = (kind == "reg" && size == 8);
        if (reference == "uw") uw_ok = (kind == "wire");
        if (reference == "mem") array_seen = 1;
        if (!is_1364_type(kind)) extension_seen = 1;
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
      end else if (token == "$date" || token == "$version" || token == "$timescale" ||
                   token == "$scope" || token == "$upscope" || token == "$comment" ||
                   token == "$enddefinitions") begin
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
      end
    end
    $fclose(fd);
    $display("bit is reg with its packed width: %0d", b1_ok && b4_ok && l8_ok);
    $display("byte shortint longint and int map to their sizes: %0d",
             by_ok && si_ok && li_ok && iv_ok);
    $display("an untyped enum is integer 32: %0d", de_ok);
    $display("a typed enum uses its declared type: %0d", se_ok && le_ok);
    $display("shortreal maps to real: %0d", sr_ok);
    $display("packed arrays and structures are one reg vector: %0d", ps_ok && pa_ok);
    $display("uwire maps to wire: %0d", uw_ok);
    $display("the unpacked array is not dumped: %0d", !array_seen);
    $display("every var type is an IEEE 1364-2005 type: %0d", !extension_seen);
  endtask

  initial begin
    mem[0] = 2'b10;
    mem[1] = 2'b01;
    $dumpfile("types.vcd");
    $dumpvars(0, test_vcd_type_mappings);
    #1 $dumpflush;
    read_dump();
  end
endmodule
