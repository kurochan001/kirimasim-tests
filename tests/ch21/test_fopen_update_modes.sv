/*
:name: test_fopen_update_modes
:description: $fopen with "r+", "r+b" or "rb+" opens an existing file for reading and writing without truncating it, "w+", "w+b" or "wb+" truncates or creates a file for update, and "a+", "a+b" or "ab+" opens or creates a file for update with writes at its end (IEEE 1800-2023 Section 21.3.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.1 21.3.4.1 21.3.4.2 21.3.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_fopen_update_modes.expected
*/
// IEEE 1800-2023 §21.3.1, Table 21-6: "r+", "r+b" and "rb+" open a file for
// update, reading and writing; "w+", "w+b" and "wb+" truncate the file or
// create it, for update; "a+", "a+b" and "ab+" open or create it for update
// at the end of the file. Each file below is first prepared with "w" where
// it has to exist, then opened in an update mode, read with $fgetc or
// $fgets (§21.3.4) and written with $fwrite, with $fseek (§21.3.5) between
// reading and writing. The r modes read the old first character and then
// overwrite characters in place, keeping the rest; the w modes find the
// existing file empty (the first $fgetc gives -1) or create it; the a modes
// add their line after the old content, which is still there to be read.
// The test creates its files in the current directory.
// In release 5.052 of Verilator a read after $fwrite and $fseek on a file
// opened for update does not see the written data or reads nothing.

module test_fopen_update_modes;
  int fd, c, r;
  string l;

  function automatic string chomp(string s);
    if (s.len() > 0 && s[s.len() - 1] == "\n") return s.substr(0, s.len() - 2);
    return s;
  endfunction

  task automatic prepare(string name, string text);
    int w;
    w = $fopen(name, "w");
    $fdisplay(w, "%s", text);
    $fclose(w);
  endtask

  task automatic read_all(string tag);
    $write("%s:", tag);
    r = $fseek(fd, 0, 0);
    while ($fgets(l, fd) != 0) $write(" [%s]", chomp(l));
    $display;
  endtask

  initial begin
    prepare("test_fopen_update_modes_r1.txt", "abcdef");
    fd = $fopen("test_fopen_update_modes_r1.txt", "r+");
    c = $fgetc(fd);
    r = $fseek(fd, 0, 0);
    $fwrite(fd, "XY");
    read_all($sformatf("r+ first=%c", c));
    $fclose(fd);

    prepare("test_fopen_update_modes_r2.txt", "123456");
    fd = $fopen("test_fopen_update_modes_r2.txt", "r+b");
    c = $fgetc(fd);
    r = $fseek(fd, 2, 0);
    $fwrite(fd, "Q");
    read_all($sformatf("r+b first=%c", c));
    $fclose(fd);

    prepare("test_fopen_update_modes_r3.txt", "uvwxyz");
    fd = $fopen("test_fopen_update_modes_r3.txt", "rb+");
    c = $fgetc(fd);
    r = $fseek(fd, 5, 0);
    $fwrite(fd, "Z");
    read_all($sformatf("rb+ first=%c", c));
    $fclose(fd);

    prepare("test_fopen_update_modes_w1.txt", "old text");
    fd = $fopen("test_fopen_update_modes_w1.txt", "w+");
    c = $fgetc(fd);
    r = $fseek(fd, 0, 0);
    $fwrite(fd, "fresh\n");
    read_all($sformatf("w+ first=%0d", c));
    $fclose(fd);

    fd = $fopen("test_fopen_update_modes_w2.txt", "w+b");
    $fwrite(fd, "made\n");
    read_all("w+b new");
    $fclose(fd);

    prepare("test_fopen_update_modes_w3.txt", "zzz");
    fd = $fopen("test_fopen_update_modes_w3.txt", "wb+");
    c = $fgetc(fd);
    r = $fseek(fd, 0, 0);
    $fwrite(fd, "new\n");
    read_all($sformatf("wb+ first=%0d", c));
    $fclose(fd);

    prepare("test_fopen_update_modes_a1.txt", "base");
    fd = $fopen("test_fopen_update_modes_a1.txt", "a+");
    $fwrite(fd, "tail\n");
    read_all("a+");
    $fclose(fd);

    fd = $fopen("test_fopen_update_modes_a2.txt", "a+b");
    $fwrite(fd, "first\n");
    read_all("a+b new");
    $fclose(fd);

    prepare("test_fopen_update_modes_a3.txt", "m1");
    fd = $fopen("test_fopen_update_modes_a3.txt", "ab+");
    $fwrite(fd, "m2\n");
    read_all("ab+");
    $fclose(fd);
  end
endmodule
