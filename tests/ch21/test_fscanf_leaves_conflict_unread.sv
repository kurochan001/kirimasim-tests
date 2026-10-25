/*
:name: test_fscanf_leaves_conflict_unread
:description: $fscanf leaves the character that ends a conversion or fails to match an ordinary character, and trailing white space that no directive matches, unread for the next read, and neither a matched ordinary character nor a suppressed conversion counts in its result (IEEE 1800-2023 Section 21.3.4.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3 21.3.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_fscanf_leaves_conflict_unread.expected
*/
// IEEE 1800-2023 §21.3.4.3: when a conversion ends on a conflicting input
// character, that character stays unread in the input; white space after the
// last field also stays unread unless a directive matches it. The result
// counts only the items assigned, so the matched ordinary characters and the
// suppressed conversions do not show in it. The file holds "12a;34 ,56", two
// spaces, a newline and "z 77 88 99;". After each $fscanf, $fgetc (21.3.4.1)
// returns the next unread character: a after %d reads 12, the space after
// ";%d," reads 34 and fails to match the comma, and a space after ",%d" reads
// 56. " %c" then skips the white space and reads z; "%*d %d" returns 1, and
// "%*d,%d" reads 99 without assigning it, fails to match the comma with the
// semicolon, which stays unread, and returns 0. The file is created in the
// current directory. The 5.052 release of Verilator skips the space before
// matching the comma of ";%d,".

module test_fscanf_leaves_conflict_unread;
  int fd, n, x, c;

  initial begin
    fd = $fopen("test_fscanf_leaves_conflict_unread.txt", "w");
    $fwrite(fd, "12a;34 ,56  \nz 77 88 99;");
    $fclose(fd);

    fd = $fopen("test_fscanf_leaves_conflict_unread.txt", "r");
    n = $fscanf(fd, "%d", x);
    c = $fgetc(fd);
    $display("%%d: n=%0d x=%0d next=%0d", n, x, c);
    n = $fscanf(fd, ";%d,", x);
    c = $fgetc(fd);
    $display(";%%d,: n=%0d x=%0d next=%0d", n, x, c);
    n = $fscanf(fd, ",%d", x);
    c = $fgetc(fd);
    $display(",%%d: n=%0d x=%0d next=%0d", n, x, c);
    n = $fscanf(fd, " %c", c);
    $display(" %%c: n=%0d c=%0d", n, c);
    n = $fscanf(fd, "%*d %d", x);
    $display("%%*d %%d: n=%0d x=%0d", n, x);
    n = $fscanf(fd, "%*d,%d", x);
    c = $fgetc(fd);
    $display("%%*d,%%d: n=%0d x=%0d next=%0d", n, x, c);
    $fclose(fd);
  end
endmodule
