/*
:name: test_fflush_mcd_fd_and_all
:description: $fflush with a multichannel descriptor writes out the buffered output of every file it selects, with a file descriptor that of its file, and without an argument that of all open files, so a second descriptor reads the text while the files are still open (IEEE 1800-2023 Section 21.3.6)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.6 21.3.1 21.3.2 21.3.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_fflush_mcd_fd_and_all.expected
*/
// IEEE 1800-2023 §21.3.6: $fflush(mcd) writes any buffered output to the files
// the multichannel descriptor selects, $fflush(fd) to the file of the
// descriptor, and $fflush() to all open files. Two files are opened without a
// type, which gives multichannel descriptors (21.3.1), and two with "w". After
// each write and flush, and while the writers stay open, each file is read
// from a new descriptor with $fgets (21.3.4.2), which shows the text that has
// reached the file. The files are created in the current directory. With the
// 5.052 release of Verilator, $fflush() does not write out the line added to
// the file of m1.

module test_fflush_mcd_fd_and_all;
  int m1, m2, f3, f4;

  task automatic show(string name);
    int fr = $fopen(name, "r");
    string line, all = "";
    while ($fgets(line, fr) != 0) all = {all, line.substr(0, line.len() - 2), ";"};
    $fclose(fr);
    $display("%s: %s", name, all);
  endtask

  initial begin
    m1 = $fopen("test_fflush_1.txt");
    m2 = $fopen("test_fflush_2.txt");
    f3 = $fopen("test_fflush_3.txt", "w");
    f4 = $fopen("test_fflush_4.txt", "w");

    $fdisplay(m1 | m2, "both");
    $fflush(m1 | m2);
    show("test_fflush_1.txt");
    show("test_fflush_2.txt");

    $fdisplay(f3, "three");
    $fflush(f3);
    show("test_fflush_3.txt");

    $fdisplay(m1, "one more");
    $fdisplay(f4, "four");
    $fflush();
    show("test_fflush_1.txt");
    show("test_fflush_4.txt");

    $fclose(m1 | m2);
    $fclose(f3);
    $fclose(f4);
  end
endmodule
