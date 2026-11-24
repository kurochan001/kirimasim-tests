/*
:name: test_file_binary_seek_counts_all_bytes_before_eof
:description: Binary seek counts embedded control bytes and distinguishes a high byte from EOF
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.1 21.3.5 21.3.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_file_binary_seek_counts_all_bytes_before_eof.expected
:expected_exit: 0
*/
module test_file_binary_seek_counts_all_bytes_before_eof;
  localparam PATH = "binary-seek.bin";

  initial begin
    int fd, seek_status, position, marker, high_byte, eof_value, rewind_status, first;
    fd = $fopen(PATH, "wb");
    if (fd == 0) $fatal(1, "cannot create the binary fixture");
    $fwrite(fd, "%c%c%c%c%c%c", 65, 13, 10, 0, 26, 255);
    $fclose(fd);
    fd = $fopen(PATH, "rb");
    if (fd == 0) $fatal(1, "cannot read the binary fixture");
    seek_status = $fseek(fd, -2, 2);
    position = $ftell(fd);
    marker = $fgetc(fd);
    high_byte = $fgetc(fd);
    eof_value = $fgetc(fd);
    rewind_status = $rewind(fd);
    first = $fgetc(fd);
    $display("seek=%0d offset=%0d marker=%0d high=%0d eof=%0d rewind=%0d first=%0d",
             seek_status, position, marker, high_byte, eof_value, rewind_status, first);
    $fclose(fd);
  end
endmodule
