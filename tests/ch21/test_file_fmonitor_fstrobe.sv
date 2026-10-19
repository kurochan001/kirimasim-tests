/*
:name: test_file_fmonitor_fstrobe
:description: several $fmonitor tasks can be active at once, each writing to its file at the end of every time step in which one of its arguments changed, $fstrobe writes the values at the end of the time step, and $fclose cancels them (IEEE 1800-2023 Section 21.3.2)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.2 21.2.2 21.2.3 21.3.1 21.3.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_file_fmonitor_fstrobe.expected
*/
// IEEE 1800-2023 §21.3.2: $fmonitor and $fstrobe work like $monitor (§21.2.3)
// and $strobe (§21.2.2) but write to a file; unlike $monitor, any number of
// $fmonitor tasks can be active at the same time, and $fclose cancels the
// active $fmonitor and $fstrobe tasks of the file. A monitor writes once at
// the end of each time step in which one of its arguments other than $time
// changed, with the values of that moment, and a strobe writes once at the
// end of its time step. The test writes two files in the current directory
// (§21.3.1) and prints them with $fgets (§21.3.4.2).

module test_file_fmonitor_fstrobe;
  int fa, fb;
  int v = 0, w = 0, u = 0;
  string line;

  task automatic print_file(string name);
    int fd = $fopen(name, "r");
    while ($fgets(line, fd) != 0) $write("%s: %s", name, line);
    $fclose(fd);
  endtask

  initial begin
    fa = $fopen("test_file_fmonitor_fstrobe_a.txt", "w");
    fb = $fopen("test_file_fmonitor_fstrobe_b.txt", "w");
    $fmonitor(fa, "%0d: v=%0d", $time, v);
    $fmonitor(fb, "%0d: w=%0d", $time, w);
    #1 v = 1;
    v = 2;
    #1 $fstrobe(fb, "%0d: strobe u=%0d", $time, u);
    u = 7;
    #1 w = 5;
    #1 $fclose(fb);
    w = 6;
    #1 v = 3;
    #1 $fclose(fa);
    print_file("test_file_fmonitor_fstrobe_a.txt");
    print_file("test_file_fmonitor_fstrobe_b.txt");
  end
endmodule
