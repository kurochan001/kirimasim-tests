/*
:name: test_fd_no_broadcast
:description: Two file descriptors combined with a bitwise OR do not direct one write to both files, while each descriptor still writes its own file (IEEE 1800-2023 Section 21.3.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_fd_no_broadcast.expected
*/
// IEEE 1800-2023 §21.3.1: a multichannel descriptor directs output to
// several files when its bits are combined, but file descriptors cannot be
// combined by a bitwise OR to do that; a file opened with a type is written
// through its own descriptor. The test opens two files for writing, writes
// through their OR, then writes one word through each descriptor, closes
// both and reads them back. The OR value must not put its word into both
// files, while each file must hold the word written through its own
// descriptor.

module test_fd_no_broadcast;
  integer fd1, fd2, both, fdr, count;
  string line;
  bit combined1, combined2, only1, only2;

  task automatic read_one(string name, output bit combined, output bit own);
    integer fd;
    string text;
    combined = 0;
    own = 0;
    fd = $fopen(name, "r");
    if (fd == 0) $fatal(1, "a written file is missing");
    while ($fgets(text, fd) > 0) begin
      if (text.len() >= 8 && text.substr(0, 7) == "combined") combined = 1;
      if (text.len() >= 3 && text.substr(0, 2) == "one") own = 1;
      if (text.len() >= 3 && text.substr(0, 2) == "two") own = 1;
    end
    $fclose(fd);
  endtask

  initial begin
    fd1 = $fopen("fd_one.txt", "w");
    fd2 = $fopen("fd_two.txt", "w");
    if (fd1 == 0 || fd2 == 0 || fd1 == fd2) $fatal(1, "the files did not open");
    both = fd1 | fd2;
    $fwrite(both, "combined\n");
    $fwrite(fd1, "one\n");
    $fwrite(fd2, "two\n");
    $fclose(fd1);
    $fclose(fd2);
    read_one("fd_one.txt", combined1, only1);
    read_one("fd_two.txt", combined2, only2);
    $display("the two descriptors are distinct and nonzero: %0d", fd1 != fd2);
    $display("the OR does not write to both files: %0d", !(combined1 && combined2));
    $display("each descriptor writes its own file: %0d", only1 && only2);
  end
endmodule
