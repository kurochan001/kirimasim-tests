/*
:name: test_file_read_functions_all_forms
:description: Every form of the file read functions works on one file: $fgetc, $ungetc, $fgets, $fscanf, $sscanf, $fread into an integral variable and $fread into a memory with no address arguments, with start, with start and count, and with count alone (IEEE 1800-2023 Section 21.3.4)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4 21.3.4.1 21.3.4.2 21.3.4.3 21.3.4.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_file_read_functions_all_forms.expected
*/
// IEEE 1800-2023 §21.3.4, Syntax 21-7: the file read functions are $fgetc(fd),
// $ungetc(c, fd), $fgets(str, fd), $fscanf(fd, format, args), $sscanf(str,
// format, args), $fread(integral_var, fd) and $fread(mem, fd) with an optional
// start and an optional count, either of which can be left out. A file opened
// with "r" can be read. The test writes "Q7 line\n", "12 34\n" and then the
// bytes 41 to 4c (hex), and reads it with each form in turn; each $fread into
// the 4-word memory m shows which words it loaded (21.3.4.4: from start, or
// from the lowest address, at most count words). The words not loaded keep 00.
// The file is created in the current directory. Icarus Verilog 13.0 rejects
// $fread with an empty start argument.

module test_file_read_functions_all_forms;
  int fd, c, code, a, b;
  string line;
  logic [15:0] w;
  logic [7:0] m [0:3];

  task automatic show_m(string form);
    $display("%s: code=%0d m=%h %h %h %h", form, code, m[0], m[1], m[2], m[3]);
    foreach (m[i]) m[i] = 8'h00;
  endtask

  initial begin
    fd = $fopen("test_file_read_functions_all_forms.txt", "w");
    $fwrite(fd, "Q7 line\n12 34\n");
    for (int i = 'h41; i <= 'h4c; i++) $fwrite(fd, "%c", i[7:0]);
    $fclose(fd);
    foreach (m[i]) m[i] = 8'h00;

    fd = $fopen("test_file_read_functions_all_forms.txt", "r");
    c = $fgetc(fd);
    $display("$fgetc: %c", c);
    code = $ungetc(c, fd);
    $display("$ungetc: code=%0d", code);
    code = $fgets(line, fd);
    $display("$fgets: code=%0d %s", code, line.substr(0, line.len() - 2));
    code = $sscanf(line, "Q%d", a);
    $display("$sscanf: code=%0d a=%0d", code, a);
    code = $fscanf(fd, "%d %d ", a, b);
    $display("$fscanf: code=%0d a=%0d b=%0d", code, a, b);
    code = $fread(w, fd);
    $display("$fread integral: code=%0d w=%h", code, w);
    code = $fread(m, fd);
    show_m("$fread mem");
    code = $fread(m, fd, 2);
    show_m("$fread mem start");
    code = $fread(m, fd, 1, 1);
    show_m("$fread mem start count");
    code = $fread(m, fd, , 2);
    show_m("$fread mem count");
    $fclose(fd);
  end
endmodule
