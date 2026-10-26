/*
:name: test_vcd_vector_extension_and_event
:description: Vector value changes remove the redundant left-extension bits, keep no space after the base letter and one space before the identifier, scalars have no space, and an event is a scalar identifier at its trigger time (IEEE 1800-2023 Sections 21.7.2.1 and 21.7.2.2)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.2.1 21.7.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_vcd_vector_extension_and_event.expected
*/
// IEEE 1800-2023 §21.7.2.1: the vector-dump rule dumps the whole vector.
// §21.7.2.2: a vector value keeps its shortest form, removing the redundant
// bits that left-extension adds, a leading 0 being extended with 0 and a
// leading z with z; a vector change has no white space between the base
// letter and the digits and one white space between the digits and the
// identifier code, a scalar change has none at all, and an event uses the
// scalar form whose identifier marks the trigger in that time step. The test
// dumps 8'b0000_0101, 8'bzzzz_0101 and 16'bxxxx_0000_1010_0101, triggers an
// event at time 10, and reads the file by tokens; after a vector token it
// reads the next two characters to count the separating white space.

`timescale 1ns/1ns

module test_vcd_vector_extension_and_event;
  logic [7:0] zero_pad = 8'b0000_0101;
  logic [7:0] z_pad = 8'bzzzz_0101;
  logic [15:0] x_pad = 16'bxxxx_0000_1010_0101;
  logic [7:0] whole = 8'hA5;
  event ev;

  function automatic bit is_space(int c);
    return c == 32 || c == 9 || c == 10 || c == 12 || c == 13;
  endfunction

  function automatic bit is_digit(int c);
    return c == "0" || c == "1" || c == "x" || c == "X" || c == "z" || c == "Z";
  endfunction

  task automatic read_dump();
    int fd, c1, c2, at = -1;
    string token, kind, size, code, reference, digits, id;
    string zero_code = "", z_code = "", x_code = "", whole_code = "", event_code = "";
    string zero_digits = "", z_digits = "", x_digits = "", whole_digits = "";
    bit sim = 0, spacing_ok = 1, scalar_ok = 1, digits_ok = 1, event_ok = 0;

    fd = $fopen("vector.vcd", "r");
    if (fd == 0) $fatal(1, "the dump file is missing");
    while ($fscanf(fd, "%s", token) == 1) begin
      if (token == "$var") begin
        void'($fscanf(fd, "%s %s %s %s", kind, size, code, reference));
        if (reference == "zero_pad") zero_code = code;
        if (reference == "z_pad") z_code = code;
        if (reference == "x_pad") x_code = code;
        if (reference == "whole") whole_code = code;
        if (reference == "ev") event_code = code;
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
      end else if (token == "$enddefinitions") begin
        sim = 1;
      end else if (token == "$comment") begin
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
      end else if (token == "$date" || token == "$version" || token == "$timescale" ||
                   token == "$scope" || token == "$upscope") begin
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
      end else if (sim && token.substr(0, 0) == "#") begin
        digits = token.substr(1, token.len() - 1);
        at = digits.atoi();
      end else if (sim && (token.substr(0, 0) == "b" || token.substr(0, 0) == "B")) begin
        digits = token.substr(1, token.len() - 1);
        c1 = $fgetc(fd);
        c2 = $fgetc(fd);
        if (!is_space(c1) || c2 < 0 || is_space(c2)) spacing_ok = 0;
        if (c2 >= 0) c1 = $ungetc(c2, fd);
        if ($fscanf(fd, "%s", id) != 1) spacing_ok = 0;
        if (digits.len() == 0) digits_ok = 0;
        for (int i = 0; i < digits.len(); i++)
          if (!is_digit(digits[i])) digits_ok = 0;
        if (id == zero_code && zero_digits == "") zero_digits = digits;
        if (id == z_code && z_digits == "") z_digits = digits;
        if (id == x_code && x_digits == "") x_digits = digits;
        if (id == whole_code && whole_digits == "") whole_digits = digits;
      end else if (sim && (token.substr(0, 0) == "0" || token.substr(0, 0) == "1" ||
                           token.substr(0, 0) == "x" || token.substr(0, 0) == "X" ||
                           token.substr(0, 0) == "z" || token.substr(0, 0) == "Z")) begin
        id = token.substr(1, token.len() - 1);
        if (token.len() < 2) scalar_ok = 0;
        for (int i = 0; i < id.len(); i++)
          if (is_space(id[i])) scalar_ok = 0;
        if (id == event_code && at == 10) event_ok = 1;
      end
    end
    $fclose(fd);
    $display("no redundant left-extension digits: %0d",
             zero_digits == "101" && z_digits == "z0101" &&
             x_digits == "x000010100101");
    $display("vector values have one space before the identifier: %0d", spacing_ok);
    $display("scalar values have no space before the identifier: %0d", scalar_ok);
    $display("vector digits use only 0 1 x and z: %0d", digits_ok);
    $display("the event id marks a scalar at its trigger time: %0d", event_ok);
    $display("the whole vector is dumped: %0d", whole_digits == "10100101");
  endtask

  initial begin
    $dumpfile("vector.vcd");
    $dumpvars(0, test_vcd_vector_extension_and_event);
    #10 -> ev;
    #10 z_pad = 8'bzzzz_0011;
    x_pad = 16'hx;
    zero_pad = 8'h00;
    #10 $dumpflush;
    read_dump();
  end
endmodule
