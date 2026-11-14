/*
:name: test_unformatted_u_z_in_display_and_scan_tasks
:description: The unformatted specifiers %u and %z work in display tasks other than $fwrite ($display, $write, $displayh, $writeb, $displayo, $strobe, $fdisplay, $fwriteh, $fdisplayb and $fstrobe), each writing the same bytes as $fwrite, and in $sscanf as well as $fscanf (IEEE 1800-2023 Sections 21.2.1.1 and 21.3.4.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.1 21.3.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_unformatted_u_z_in_display_and_scan_tasks.expected
*/
// IEEE 1800-2023 §21.2.1.1: %u (or %U) writes the 2-state binary form of its
// value and %z (or %Z) its 4-state form, an aval word and then a bval word
// for each 32 bits, without formatting. Either one can be used in any of the
// display tasks, although $fwrite is the one to prefer. §21.3.4.3, Table
// 21-7: in the same way %u and %z read binary data in any input task that
// takes a format, although $fscanf is the one to prefer; %u fills its target
// from 4 bytes per 32 bits as 2-state data, and %z from an aval and a bval
// word per 32 bits.
// The 32-bit value u is 41 42 42 41 (hex), the bytes of "ABBA" in either
// byte order of the host. The 4-state value q has the aval word 41 42 42 41
// and the bval word 43 44 44 43 ("CDDC"); its bits are 0, 1, x and z
// (§38.15: aval 1 with bval 0 is 1, 0 with 1 is z, 1 with 1 is x), so %z
// writes "ABBACDDC" and %u of u writes "ABBA" on any host.
// Six display tasks write to the standard output: the printed text is those
// bytes. Five file tasks, including $fwrite, write a file with "wb", whose
// lines are then read back with $fgets; $fscanf and $sscanf read the bytes
// back with %u and %z, and the values are printed in hex for u and in binary
// for q. The file is created in the current directory.
// The scan formats are written in lower case: Icarus Verilog 13.0 reports %U
// and %Z in $fscanf and $sscanf as invalid format codes. In the 5.054 release
// of Verilator, a two-state simulator, %z in a display task writes other bytes
// than the aval and bval words.

module test_unformatted_u_z_in_display_and_scan_tasks;
  logic [31:0] u = 32'h4142_4241;
  logic [31:0] q = {8'b0x0000zx, 8'b0x000z10, 8'b0x000z10, 8'b0x0000zx};
  logic [31:0] r1, r2, r3;
  int fd, code, c;
  string line;
  string s = "ABBACDDCABBA";

  function automatic string chomp(string t);
    if (t.len() > 0 && t[t.len() - 1] == "\n") return t.substr(0, t.len() - 2);
    return t;
  endfunction

  initial begin
    $display("%u", u);
    $write("w[%U]\n", u);
    $displayh("h %u", u);
    $writeb("b %z\n", q);
    $displayo("o %Z", q);
    #1 $strobe("s %u %z", u, q);

    #1 fd = $fopen("test_unformatted_u_z_in_display_and_scan_tasks.bin", "wb");
    $fwrite(fd, "%u", u);
    $fdisplay(fd, "%u", u);
    $fwriteh(fd, "%z|", q);
    $fdisplayb(fd, "%U", u);
    $fstrobe(fd, "%Z", q);
    #1 $fclose(fd);

    fd = $fopen("test_unformatted_u_z_in_display_and_scan_tasks.bin", "rb");
    while ($fgets(line, fd) != 0) $display("file: %s", chomp(line));
    $fclose(fd);

    fd = $fopen("test_unformatted_u_z_in_display_and_scan_tasks.bin", "rb");
    code = $fscanf(fd, "%u%u", r1, r2);
    $display("fscanf %%u%%u: %0d %h %h", code, r1, r2);
    c = $fgetc(fd);
    code = $fscanf(fd, "%z|%u", r1, r2);
    $display("fscanf %%z|%%u: %0d %b %h", code, r1, r2);
    c = $fgetc(fd);
    code = $fscanf(fd, "%z", r3);
    $display("fscanf %%z: %0d %b", code, r3);
    $fclose(fd);

    code = $sscanf(s, "%z%u", r1, r2);
    $display("sscanf %%z%%u: %0d %b %h", code, r1, r2);
    code = $sscanf(s, "%u", r3);
    $display("sscanf %%u: %0d %h", code, r3);
  end
endmodule
