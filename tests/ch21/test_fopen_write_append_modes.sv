/*
:name: test_fopen_write_append_modes
:description: $fopen with "w" or "wb" truncates an existing file or creates a new one for writing, and with "a" or "ab" writes at the end of an existing file or creates a new one (IEEE 1800-2023 Section 21.3.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.1 21.3.2 21.3.4.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_fopen_write_append_modes.expected
*/
// IEEE 1800-2023 §21.3.1, Table 21-6: the type "w" or "wb" truncates the file
// to zero length or creates it, for writing; "a" or "ab" opens it for
// writing at its end, or creates it. The test writes lines with $fdisplay
// (§21.3.2) and after each step reads the whole file back with $fgets
// (§21.3.4.2), printing its lines on one line.
// File a is created with "w", extended with "a" and with "ab", then
// truncated by "w" and again by "wb". Files b, c and d do not exist before
// they are opened with "a", "ab" and "wb", which create them. The test
// creates its files in the current directory.

module test_fopen_write_append_modes;
  localparam string A = "test_fopen_write_append_modes_a.txt";
  int fd;

  function automatic string chomp(string s);
    if (s.len() > 0 && s[s.len() - 1] == "\n") return s.substr(0, s.len() - 2);
    return s;
  endfunction

  task automatic show(string tag, string name);
    int rd;
    string l;
    rd = $fopen(name, "r");
    $write("%s:", tag);
    while ($fgets(l, rd) != 0) $write(" [%s]", chomp(l));
    $display;
    $fclose(rd);
  endtask

  initial begin
    fd = $fopen(A, "w");
    $fdisplay(fd, "one");
    $fdisplay(fd, "two");
    $fclose(fd);
    show("w", A);
    fd = $fopen(A, "a");
    $fdisplay(fd, "three");
    $fclose(fd);
    show("a", A);
    fd = $fopen(A, "ab");
    $fdisplay(fd, "four");
    $fclose(fd);
    show("ab", A);
    fd = $fopen(A, "w");
    $fdisplay(fd, "five");
    $fclose(fd);
    show("w again", A);
    fd = $fopen(A, "wb");
    $fdisplay(fd, "six");
    $fclose(fd);
    show("wb", A);
    fd = $fopen("test_fopen_write_append_modes_b.txt", "a");
    $fdisplay(fd, "made by a");
    $fclose(fd);
    show("a new", "test_fopen_write_append_modes_b.txt");
    fd = $fopen("test_fopen_write_append_modes_c.txt", "ab");
    $fdisplay(fd, "made by ab");
    $fclose(fd);
    show("ab new", "test_fopen_write_append_modes_c.txt");
    fd = $fopen("test_fopen_write_append_modes_d.txt", "wb");
    $fdisplay(fd, "made by wb");
    $fclose(fd);
    show("wb new", "test_fopen_write_append_modes_d.txt");
  end
endmodule
