/*
:name: test_string_putc_index_rules
:description: putc(i, c) acts like str[i] = c, ignores an index outside 0 to len()-1 and a zero character, never changes the length, and converts its arguments to int and byte (IEEE 1800-2023 Section 6.16.2)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.2 6.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_putc_index_rules.expected
*/
// IEEE 1800-2023 §6.16.2: putc(int i, byte c) replaces character i of the
// string with c. It does not change the length: an index below 0 or not
// below len() leaves the string unchanged, and so does a zero character.
// str.putc(j, x) means the same as str[j] = x (§6.16: assigning 0 to a
// character is ignored). Each step is done with putc on a and with an index
// assignment on b, and both are printed with the length of a. The index
// 64'h1_0000_0003 becomes the int 3, and the character 16'h0148 becomes the
// byte 8'h48 ("H") while 16'h0100 becomes the byte 0, which is ignored.
// Icarus Verilog 13.0 does not know the putc method (unsupported construct).

module test_string_putc_index_rules;
  string a = "hello", b = "hello", e;
  int i;

  task automatic show(string label);
    $display("%s: a=\"%s\" b=\"%s\" len=%0d", label, a, b, a.len());
  endtask

  initial begin
    a.putc(1, "E");  b[1] = "E";  show("index 1");
    i = 4;
    a.putc(i, 8'h21); b[i] = 8'h21; show("index 4");
    i = -1;
    a.putc(i, "X");  b[i] = "X";  show("index -1");
    i = 5;
    a.putc(i, "X");  b[i] = "X";  show("index 5");
    i = 99;
    a.putc(i, "X");  b[i] = "X";  show("index 99");
    a.putc(2, 0);    b[2] = 0;    show("zero");
    a.putc(2, 16'h0100); b[2] = 16'h0100; show("16'h0100");
    a.putc(0, 16'h0148); b[0] = 16'h0148; show("16'h0148");
    a.putc(64'h1_0000_0003, "L"); show("64'h1_0000_0003");
    e.putc(0, "A");
    $display("empty: e=\"%s\" len=%0d", e, e.len());
  end
endmodule
