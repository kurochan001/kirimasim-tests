/*
:name: test_fgets_fill_newline_eof
:description: $fgets stops when its variable is full, counting only whole bytes of it, after a newline, which it keeps, or at the end of the file, and returns the number of characters read, or 0 when it reads none or cannot read (IEEE 1800-2023 Section 21.3.4.2)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.2 21.3.1 21.3.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_fgets_fill_newline_eof.expected
*/
// IEEE 1800-2023 §21.3.4.2: $fgets(str, fd) reads characters into str until
// str is full, until it has read a newline, which it puts into str too, or
// until the end of the file. When str is not a whole number of bytes, its
// most significant partial byte does not count, so a 28-bit str holds 3
// characters. It returns the number of characters read, and 0 when an error
// occurs. The file holds "abcdefg", a newline, "hi", a newline and "xy". A
// 32-bit str takes "abcd", a 28-bit str "efg" (not the newline after it), and
// then a string takes the lone newline, "hi" and its newline, and "xy" at the
// end; the next call reads nothing and returns 0. A descriptor opened only
// for writing cannot be read (21.3.4), so $fgets on it returns 0 as well.
// Only the whole bytes of the 28-bit str are printed. The file is created in
// the current directory. The 5.052 release of Verilator counts the partial
// byte and reads "efg" and the newline into the 28-bit str (n=4).

module test_fgets_fill_newline_eof;
  int fd, fw, n;
  bit [31:0] s4;
  bit [27:0] s3;
  string s;

  function automatic string shown(string t);
    string r = "";
    for (int i = 0; i < t.len(); i++) r = {r, t[i] == "\n" ? "<nl>" : string'(t[i])};
    return r;
  endfunction

  initial begin
    fd = $fopen("test_fgets_fill_newline_eof.txt", "w");
    $fwrite(fd, "abcdefg\nhi\nxy");
    $fclose(fd);

    fd = $fopen("test_fgets_fill_newline_eof.txt", "r");
    n = $fgets(s4, fd);
    $display("32-bit: n=%0d [%s]", n, s4);
    n = $fgets(s3, fd);
    $display("28-bit: n=%0d [%s]", n, s3[23:0]);
    n = $fgets(s, fd);
    $display("string: n=%0d [%s]", n, shown(s));
    n = $fgets(s, fd);
    $display("string: n=%0d [%s]", n, shown(s));
    n = $fgets(s, fd);
    $display("string: n=%0d [%s]", n, shown(s));
    n = $fgets(s, fd);
    $display("at the end: n=%0d", n);
    $fclose(fd);

    fw = $fopen("test_fgets_fill_newline_eof_w.txt", "w");
    $fwrite(fw, "text\n");
    n = $fgets(s, fw);
    $display("write-only descriptor: n=%0d", n);
    $fclose(fw);
  end
endmodule
