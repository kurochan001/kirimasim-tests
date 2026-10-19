/*
:name: test_writememh_readback
:description: $writememh and $writememb write files that $readmemh and $readmemb read back, without @ addresses for an unpacked array (IEEE 1800-2023 Section 21.5)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.5 21.5.3 21.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_writememh_readback.expected
*/
// IEEE 1800-2023 §21.5: $writememh and $writememb write the contents of a
// memory to a file that $readmemh and $readmemb can read, replacing the file if
// it exists; start and finish addresses limit what is written. §21.5.3: for an
// unpacked array no @ address is written. The layout of the file is otherwise
// not fixed, so the test only reads it back and looks for @. The test creates
// its files in the current directory.

module test_writememh_readback;
  logic [7:0] mem [0:3];
  logic [7:0] back [0:3];
  logic [7:0] part [0:3];
  logic [5:0] bits [0:1];
  logic [5:0] bits_back [0:1];
  int fd, c, ats;

  initial begin
    mem[0] = 8'h12; mem[1] = 8'h34; mem[2] = 8'hab; mem[3] = 8'hcd;
    $writememh("test_writememh_readback_h.mem", mem);
    $readmemh("test_writememh_readback_h.mem", back);
    $display("back = %h %h %h %h", back[0], back[1], back[2], back[3]);

    ats = 0;
    fd = $fopen("test_writememh_readback_h.mem", "r");
    c = $fgetc(fd);
    while (c != -1) begin
      if (c == "@") ats++;
      c = $fgetc(fd);
    end
    $fclose(fd);
    $display("@ characters in the file: %0d", ats);

    $writememh("test_writememh_readback_p.mem", mem, 1, 2);
    foreach (part[i]) part[i] = 8'h00;
    $readmemh("test_writememh_readback_p.mem", part, 0, 1);
    $display("part = %h %h %h %h", part[0], part[1], part[2], part[3]);

    bits[0] = 6'b101100; bits[1] = 6'b000111;
    $writememb("test_writememh_readback_b.mem", bits);
    $readmemb("test_writememh_readback_b.mem", bits_back);
    $display("bits_back = %b %b", bits_back[0], bits_back[1]);
  end
endmodule
