/*
:name: test_vcd_version_records_dumpfile_call
:description: The VCD $version section identifies the version of the writer and the $dumpfile call that made the file, and when the file name is a string variable it records the unevaluated variable expression (IEEE 1800-2023 Sections 21.7.2.3 and 21.7.1.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.2.3 21.7.1.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vcd_version_records_dumpfile_call.expected
*/
// IEEE 1800-2023 §21.7.2.3: the $version section indicates which version of
// the VCD writer produced the file and the $dumpfile system task used to
// create it; if a variable or an expression specified the filename within
// $dumpfile, the unevaluated variable or expression literal shall appear in
// the $version string, as in $dumpfile("dump1.dump"). §21.7.1.1: the filename
// is an expression of string literal, string or integral character-string
// type.
//
// The design names the file with the string variable file_name and changes a
// vector once. The reader takes the text of the $version section and checks
// that it is not empty, that it contains the $dumpfile call, and that it
// contains the variable name file_name, which is the unevaluated expression
// that the $dumpfile call used. Icarus Verilog 13.0 writes only its
// own name there and no $dumpfile text, so the expected output follows the
// clause and does not list iverilog@13.0.

`timescale 1ns/1ns

module test_vcd_version_records_dumpfile_call;
  logic [3:0] a = 4'h5;
  string file_name = "version.vcd";

  function automatic bit contains(string text, string part);
    if (part.len() == 0 || part.len() > text.len()) return 0;
    for (int i = 0; i + part.len() <= text.len(); i++)
      if (text.substr(i, i + part.len() - 1) == part) return 1;
    return 0;
  endfunction

  task automatic read_dump();
    int fd;
    string token, text = "", digits;
    bit seen = 0, writer = 0, call = 0, expression = 0;

    fd = $fopen("version.vcd", "r");
    if (fd == 0) $fatal(1, "the dump file is missing");
    while ($fscanf(fd, "%s", token) == 1) begin
      if (token == "$version") begin
        seen = 1;
        do begin
          void'($fscanf(fd, "%s", token));
          if (token != "$end") text = {text, token};
        end while (token != "$end");
      end else if (token == "$date" || token == "$comment" ||
                   token == "$timescale" || token == "$scope" ||
                   token == "$upscope" || token == "$var" ||
                   token == "$enddefinitions" || token == "$dumpvars" ||
                   token == "$dumpall" || token == "$dumpoff" ||
                   token == "$dumpon" || token == "$end") begin
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
      end else if (token[0] == "b" || token[0] == "B" ||
                   token[0] == "r" || token[0] == "R") begin
        digits = token;
        void'($fscanf(fd, "%s", token));
      end else if (token[0] == "#") begin
      end
    end
    $fclose(fd);
    writer = seen && text.len() > 0;
    call = contains(text, "$dumpfile");
    expression = contains(text, "file_name");
    $display("the version section identifies the writer: %0d", writer);
    $display("the version names the $dumpfile call: %0d", call);
    $display("the version keeps the unevaluated variable: %0d", expression);
  endtask

  initial begin
    $dumpfile(file_name);
    $dumpvars(1, test_vcd_version_records_dumpfile_call);
    #1 a = 4'hA;
    #1 $dumpflush;
    read_dump();
  end
endmodule
