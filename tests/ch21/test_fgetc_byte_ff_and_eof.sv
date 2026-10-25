/*
:name: test_fgetc_byte_ff_and_eof
:description: $fgetc returns each byte of a binary file, including the bytes FF and 80, and -1 once no byte can be read, which only a result wider than 8 bits tells apart from the byte FF (IEEE 1800-2023 Section 21.3.4.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.1 21.3.1 21.3.8
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_fgetc_byte_ff_and_eof.expected
*/
// IEEE 1800-2023 §21.3.4.1: $fgetc reads one byte of the file and returns its
// code; when it cannot read one it returns EOF, the value -1. The result is
// kept in a variable wider than 8 bits so that EOF differs from the byte FF.
// The test writes the bytes 41, FF, 80 and 7F to a binary file (21.3.1) and
// reads them back twice: into an int, where FF reads as 255 and the end as
// -1, and into an 8-bit variable, where both read as ff. §21.3.8: $feof is
// nonzero only after the failed read. The file is created in the current
// directory.

module test_fgetc_byte_ff_and_eof;
  int fd, c, i;
  logic [7:0] c8;

  initial begin
    fd = $fopen("test_fgetc_byte_ff_and_eof.bin", "wb");
    $fwrite(fd, "%c%c%c%c", 8'h41, 8'hff, 8'h80, 8'h7f);
    $fclose(fd);

    fd = $fopen("test_fgetc_byte_ff_and_eof.bin", "rb");
    for (i = 0; i < 5; i++) begin
      c = $fgetc(fd);
      $display("int read %0d: %0d eof=%0d", i, c, $feof(fd) != 0);
    end
    $fclose(fd);

    fd = $fopen("test_fgetc_byte_ff_and_eof.bin", "rb");
    c8 = $fgetc(fd);
    c8 = $fgetc(fd);
    $display("8-bit read of byte FF: %h", c8);
    c8 = $fgetc(fd);
    c8 = $fgetc(fd);
    c8 = $fgetc(fd);
    $display("8-bit read at the end: %h", c8);
    $fclose(fd);
  end
endmodule
