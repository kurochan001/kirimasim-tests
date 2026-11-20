/*
:name: test_fmonitor_radix_variants_simultaneous
:description: $fmonitorb, $fmonitorh and $fmonitoro set up on three files are active at the same time, and each writes its whole list in its own radix at the end of every time step in which one of its own arguments changes, once even when two change together (IEEE 1800-2023 Section 21.3.2)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.2 21.2.3 21.2.1.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_fmonitor_radix_variants_simultaneous.expected
*/
// IEEE 1800-2023 §21.3.2: $fmonitor and its b, h and o forms work like
// $monitor and its forms but write to the file of their descriptor, and,
// unlike $monitor, any number of them can be active at once; $fclose
// cancels an active $fmonitor. §21.2.3: each time an argument changes, the
// whole list is written at the end of the time step, once when several
// arguments change in the same step; an argument without a format is shown
// in the radix of the form. §21.2.1.3: a hexadecimal or octal digit with
// some x bits is X, one with some z bits and no x bit is Z.
// The three tasks are called at time 0 on three files, and x and y change
// after the calls in that step. x changes at 1, y at 2 and both at 3, x is
// written with the value it has at 4, and fh is closed at 5 before y
// changes at 6. So fb (x) gets lines at 0, 1 and 3; fh (x and y) at 0, 1,
// 2 and 3, one line at 3; fo (y) at 0, 2, 3 and 6. x = 6'b10x1z0 is 2X in
// hexadecimal, y = 5'b0z0z1 is 0Z and ZZ in hexadecimal and octal. The
// files are written to the current directory and read back at the end.

module test_fmonitor_radix_variants_simultaneous;
  localparam string FB = "test_fmonitor_radix_variants_simultaneous_b.txt";
  localparam string FH = "test_fmonitor_radix_variants_simultaneous_h.txt";
  localparam string FO = "test_fmonitor_radix_variants_simultaneous_o.txt";
  logic [5:0] x = 6'd0;
  logic [4:0] y = 5'd0;
  int fb, fh, fo;

  task automatic show(string name);
    int fd, r;
    string line;
    fd = $fopen(name, "r");
    r = $fgets(line, fd);
    while (r > 0) begin
      $write("%s: %s", name.substr(name.len() - 5, name.len() - 5), line);
      r = $fgets(line, fd);
    end
    $fclose(fd);
  endtask

  initial begin
    fb = $fopen(FB, "w");
    fh = $fopen(FH, "w");
    fo = $fopen(FO, "w");
    $fmonitorb(fb, "b x=", x);
    $fmonitorh(fh, "h x=", x, " y=", y);
    $fmonitoro(fo, "o y=", y);
    x = 6'b10x1z0;
    y = 5'h1f;
    #1 x = 6'b000011;
    #1 y = 5'b0z0z1;
    #1 x = 6'b111000;
    y = 5'd30;
    #1 x = 6'b111000;
    #1 $fclose(fh);
    #1 y = 5'd9;
    #1 $fclose(fb);
    $fclose(fo);
    show(FB);
    show(FH);
    show(FO);
  end
endmodule
