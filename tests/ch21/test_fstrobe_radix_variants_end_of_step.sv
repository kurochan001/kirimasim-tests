/*
:name: test_fstrobe_radix_variants_end_of_step
:description: $fstrobeb, $fstrobeh and $fstrobeo write their arguments in binary, hexadecimal or octal with the values they have at the end of the time step, after a later write in the same step from the calling process after #0, a nonblocking update and the process that the update wakes (IEEE 1800-2023 Section 21.3.2)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.2 21.2.2 21.2.1.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_fstrobe_radix_variants_end_of_step.expected
*/
// IEEE 1800-2023 §21.3.2: $fstrobe and its b, h and o forms work like
// $strobe and its forms, but write to the file of their descriptor.
// §21.2.2: the output is made at the end of the time step, when all of its
// events have occurred; an argument without a format is shown in the radix
// of the form. §21.2.1.3: an octal or hexadecimal digit whose bits are all
// z is z, one with some x bits is X, and one with some z bits and no x bit
// is Z; binary shows each bit.
// Time 1: after $fstrobeb the process changes k, and after #0, which
// resumes later in the same step, it changes bit 6 of v. Time 2: after
// $fstrobeh the process schedules v <= 7'h5a; that update wakes the always
// procedure, which sets k to 3'b1x0. Time 3: after $fstrobeo the process
// writes v and k at once. Each strobe therefore writes the last values of
// its time step: 0x0z101 and 0z1, then 5a and X, then zZ7 and 111 (the %b
// of the call applies to k). The $display lines show the values at each
// call. Only one strobe task is called in each time step, so the lines of
// the file are in a fixed order.

module test_fstrobe_radix_variants_end_of_step;
  localparam string FILE = "test_fstrobe_radix_variants_end_of_step.txt";
  logic [6:0] v = 7'd0;
  logic [2:0] k = 3'd0;
  int fd, r;
  string line;

  always @(v) if (v === 7'h5a) k = 3'b1x0;

  initial begin
    fd = $fopen(FILE, "w");
    #1;
    v = 7'b1x0z101;
    $fstrobeb(fd, "b v=", v, " k=", k);
    $display("t1 call v=%b k=%b", v, k);
    k = 3'b0z1;
    #0 v[6] = 1'b0;
    #1;
    $fstrobeh(fd, "h v=", v, " k=", k);
    $display("t2 call v=%b k=%b", v, k);
    v <= 7'h5a;
    #1;
    $fstrobeo(fd, "o v=", v, " k=%b", k);
    $display("t3 call v=%b k=%b", v, k);
    v = 7'bzzz_1111;
    k = 3'b111;
    #1;
    $fclose(fd);
    fd = $fopen(FILE, "r");
    r = $fgets(line, fd);
    while (r > 0) begin
      $write("file: %s", line);
      r = $fgets(line, fd);
    end
    $fclose(fd);
  end
endmodule
