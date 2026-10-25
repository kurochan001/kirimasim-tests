/*
:name: test_fseek_append_and_gap
:description: In append mode output goes to the end of the file whatever $fseek set and leaves the position after it; $fseek past the end does not make the file longer until data are written there, and the gap then reads as zero bytes; $fseek and $rewind return 0, and -1 for a position before the start (IEEE 1800-2023 Section 21.3.5)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.5 21.3.1 21.3.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_fseek_append_and_gap.expected
*/
// IEEE 1800-2023 §21.3.5: a file opened with "a" or "a+" (21.3.1) cannot be
// overwritten: $fseek can move the position, also for reading, but output is
// written at the end of the file and moves the position to the end of it. The
// position can be set beyond the end of the data; $fseek alone does not make
// the file longer, and when data are written there, the bytes of the gap read
// as zero. $fseek and $rewind return -1 when repositioning fails and 0
// otherwise; a position before the start of the file is used for the error.
// $fflush (21.3.6) makes the written data visible to a second descriptor that
// measures the size of the file. The files are created in the current
// directory. Icarus Verilog 13.0 and the 5.052 release of Verilator report the
// position after the appended output as 2 and 1, the position set by $fseek
// plus the bytes written, instead of the end of the file; the 5.052 release
// also reads nothing at position 1 in "a+" mode and returns 0 for the position
// before the start.

module test_fseek_append_and_gap;
  int fd, fr, code, c, pos;
  string s;

  task automatic dump(string name);
    int f = $fopen(name, "rb");
    string line = "";
    for (int ch = $fgetc(f); ch != -1; ch = $fgetc(f)) line = {line, $sformatf(" %0d", ch)};
    $fclose(f);
    $display("%s:%s", name, line);
  endtask

  initial begin
    fd = $fopen("test_fseek_append.txt", "w");
    $fwrite(fd, "abc");
    $fclose(fd);
    fd = $fopen("test_fseek_append.txt", "a");
    code = $fseek(fd, 0, 0);
    $fwrite(fd, "XY");
    pos = $ftell(fd);
    $display("a: seek=%0d position after write=%0d", code, pos);
    $fclose(fd);
    fd = $fopen("test_fseek_append.txt", "a+");
    code = $fseek(fd, 1, 0);
    c = $fgetc(fd);
    code = $fseek(fd, 0, 0);
    $fwrite(fd, "Z");
    pos = $ftell(fd);
    $display("a+: read at 1=%c seek=%0d position after write=%0d", c, code, pos);
    $fclose(fd);
    fd = $fopen("test_fseek_append.txt", "r");
    code = $fgets(s, fd);
    $fclose(fd);
    $display("file: %s", s);

    fd = $fopen("test_fseek_gap.bin", "wb");
    $fwrite(fd, "AB");
    code = $fseek(fd, 5, 0);
    pos = $ftell(fd);
    $fflush(fd);
    fr = $fopen("test_fseek_gap.bin", "rb");
    void'($fseek(fr, 0, 2));
    $display("past the end: seek=%0d position=%0d size=%0d", code, pos, $ftell(fr));
    $fclose(fr);
    $fwrite(fd, "Z");
    $fclose(fd);
    dump("test_fseek_gap.bin");

    fr = $fopen("test_fseek_gap.bin", "rb");
    code = $fseek(fr, -1, 0);
    $display("before the start: seek=%0d", code);
    code = $fseek(fr, 5, 0);
    c = $fgetc(fr);
    $display("seek to 5: seek=%0d read=%c", code, c);
    code = $rewind(fr);
    c = $fgetc(fr);
    $display("rewind: code=%0d read=%c", code, c);
    $fclose(fr);
  end
endmodule
