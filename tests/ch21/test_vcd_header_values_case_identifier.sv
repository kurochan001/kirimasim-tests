/*
:name: test_vcd_header_values_case_identifier
:description: A four-state VCD file has the date, version and timescale before the scopes and declarations, ends the declarations with enddefinitions, keeps names case-sensitive, uses printable identifier codes, writes a real with 16 significant digits and other values as 0, 1, x or z without strength or memories (IEEE 1800-2023 Sections 21.7.2 and 21.7.2.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.2 21.7.2.1 21.7.2.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_vcd_header_values_case_identifier.expected
*/
// IEEE 1800-2023 §21.7.2: four-state VCD is free format with whitespace
// between commands. §21.7.2.1: the file has the date, version and timescale
// before the variable scope and type definitions, then the changing-variable
// entries; its declaration commands are comment, date, enddefinitions, scope,
// timescale, upscope, var and version, and a scope type is module; generated
// identifier codes are printable non-whitespace ASCII characters 33 to 126;
// a real value is written with printf %.16g; other values are binary
// 0/1/x/z, without strength, and memories are not dumped; a timestamp is #
// followed by a decimal number; data is case-sensitive. §21.7.2.3: a $var
// gives the type, size, identifier code and reference name, and $upscope
// returns to the enclosing scope.
//
// The design dumps a module with a nested child instance, two nets whose
// names differ only in case, an 8-bit vector, a real of 1.0/3.0, one net
// that is x and one that is z, and an unpacked array that must stay out. The
// reader prints one boolean per rule; it does not depend on the order in
// which the dumper writes the declarations, on the codes it chooses or on
// the white space between commands.

`timescale 1ns/1ns

module vcd_case_child;
  logic child_bit = 1'b1;
endmodule

module test_vcd_header_values_case_identifier;
  string code_of[0:63];
  string name_of[0:63];
  int nvars = 0;

  logic sig = 1'b0;
  logic SIG = 1'b1;
  logic [7:0] vec = 8'hA5;
  real third = 1.0 / 3.0;
  logic xval;
  logic zval;
  logic [1:0] mem[0:1];
  vcd_case_child u();

  assign xval = 1'bx;

  function automatic int find_var(string code);
    for (int i = 0; i < nvars; i++)
      if (code_of[i] == code) return i;
    return -1;
  endfunction

  function automatic bit printable(string code);
    if (code.len() == 0) return 0;
    for (int i = 0; i < code.len(); i++)
      if (code[i] < 33 || code[i] > 126) return 0;
    return 1;
  endfunction

  function automatic bit binary_digits(string digits);
    if (digits.len() == 0) return 0;
    for (int i = 0; i < digits.len(); i++)
      if (!(digits[i] == "0" || digits[i] == "1" || digits[i] == "x" ||
            digits[i] == "X" || digits[i] == "z" || digits[i] == "Z")) return 0;
    return 1;
  endfunction

  task automatic read_dump();
    int fd, size;
    string token, kind, code, reference, digits, expected;
    bit header_ok = 1, ends_after = 1, modules = 1, dates = 0, versions = 0;
    bit scale_ok = 0, codes_ok = 1, case_ok = 0, real_ok = 0, vec_ok = 0;
    bit x_ok = 0, z_ok = 0, no_mem = 1, times_ok = 1, known = 1;
    bit types_ok = 1, date_text = 0, version_text = 0;
    int scopes = 0, upscopes = 0;
    bit in_defs = 0, seen_scope = 0;

    fd = $fopen("case.vcd", "r");
    if (fd == 0) $fatal(1, "the dump file is missing");
    while ($fscanf(fd, "%s", token) == 1) begin
      if (token == "$date") begin
        dates++;
        if (seen_scope) header_ok = 0;
        do begin
          void'($fscanf(fd, "%s", token));
          if (token != "$end") date_text = 1;
        end while (token != "$end");
      end else if (token == "$version") begin
        versions++;
        if (seen_scope) header_ok = 0;
        do begin
          void'($fscanf(fd, "%s", token));
          if (token != "$end") version_text = 1;
        end while (token != "$end");
      end else if (token == "$timescale") begin
        digits = "";
        do begin
          void'($fscanf(fd, "%s", token));
          if (token != "$end") digits = {digits, token};
        end while (token != "$end");
        if (seen_scope || digits != "1ns") scale_ok = 0;
        else scale_ok = 1;
      end else if (token == "$comment") begin
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
      end else if (token == "$scope") begin
        void'($fscanf(fd, "%s %s", kind, reference));
        seen_scope = 1;
        in_defs = 1;
        scopes++;
        if (kind != "module") modules = 0;
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
      end else if (token == "$upscope") begin
        upscopes++;
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
      end else if (token == "$var") begin
        void'($fscanf(fd, "%s %d %s %s", kind, size, code, reference));
        if (!in_defs) ends_after = 0;
        if (!printable(code)) codes_ok = 0;
        code_of[nvars] = code;
        name_of[nvars] = reference;
        nvars++;
        if (reference == "mem") no_mem = 0;
        if (kind != "event" && kind != "integer" && kind != "parameter" &&
            kind != "real" && kind != "realtime" && kind != "reg" &&
            kind != "supply0" && kind != "supply1" && kind != "time" &&
            kind != "tri" && kind != "triand" && kind != "trior" &&
            kind != "trireg" && kind != "tri0" && kind != "tri1" &&
            kind != "wand" && kind != "wire" && kind != "wor") types_ok = 0;
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
      end else if (token == "$enddefinitions") begin
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
        in_defs = 0;
      end else if (token == "$dumpvars" || token == "$dumpoff" ||
                   token == "$dumpon" || token == "$dumpall" || token == "$end") begin
      end else if (token[0] == "#") begin
        digits = token.substr(1, token.len() - 1);
        if (digits.len() == 0) times_ok = 0;
        for (int i = 0; i < digits.len(); i++)
          if (digits[i] < "0" || digits[i] > "9") times_ok = 0;
        if (in_defs) ends_after = 0;
      end else if (token[0] == "b" || token[0] == "B" ||
                   token[0] == "r" || token[0] == "R") begin
        void'($fscanf(fd, "%s", code));
        digits = token.substr(1, token.len() - 1);
        if (find_var(code) >= 0) expected = name_of[find_var(code)];
        else expected = "";
        if (token[0] == "r" || token[0] == "R") begin
          if (expected == "third" && digits == $sformatf("%.16g", third)) real_ok = 1;
        end else if (expected == "vec") begin
          if (binary_digits(digits)) vec_ok = 1;
        end
      end else if (token[0] == "0" || token[0] == "1" ||
                   token[0] == "x" || token[0] == "X" ||
                   token[0] == "z" || token[0] == "Z") begin
        code = token.substr(1, token.len() - 1);
        if (find_var(code) >= 0) expected = name_of[find_var(code)];
        else expected = "";
        if (expected == "xval" && (token[0] == "x" || token[0] == "X")) x_ok = 1;
        if (expected == "zval" && (token[0] == "z" || token[0] == "Z")) z_ok = 1;
      end else begin
        known = 0;
      end
    end
    $fclose(fd);
    begin
      int lo = -1, up = -1;
      for (int i = 0; i < nvars; i++) begin
        if (name_of[i] == "sig") lo = i;
        if (name_of[i] == "SIG") up = i;
      end
      case_ok = lo >= 0 && up >= 0 && code_of[lo] != code_of[up];
    end
    $display("the date, version and timescale come before the scopes: %0d",
             header_ok && dates > 0 && versions > 0 && scale_ok);
    $display("the date identifies when the file was made: %0d", date_text);
    $display("enddefinitions after every declaration: %0d", ends_after);
    $display("every scope is a module: %0d", modules);
    $display("one upscope for every scope: %0d", upscopes == scopes);
    $display("names keep their case: %0d", case_ok);
    $display("identifier codes are printable: %0d", codes_ok);
    $display("the real has 16 significant digits: %0d", real_ok);
    $display("the vector uses 0, 1, x and z: %0d", vec_ok);
    $display("the x net is x and the z net is z: %0d", x_ok && z_ok);
    $display("the memory is not dumped: %0d", no_mem);
    $display("timestamps are decimal: %0d", times_ok);
    $display("every var type is a VCD type: %0d", types_ok);
    $display("no token outside the VCD syntax: %0d", known && zval === 1'bz);
  endtask

  initial begin
    mem[0] = 2'b10;
    mem[1] = 2'b01;
    zval = 1'bz;
    $dumpfile("case.vcd");
    $dumpvars(1, test_vcd_header_values_case_identifier);
    #2 $dumpflush;
    read_dump();
  end
endmodule
