/*
:name: test_fclose_cancels_fmonitor_fstrobe
:description: $fclose cancels the $fmonitor and the pending $fstrobe of the closed descriptor, so nothing from them reaches the file that next gets the same channel (IEEE 1800-2023 Section 21.3.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.1 21.3.2 21.3.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_fclose_cancels_fmonitor_fstrobe.expected
*/
// IEEE 1800-2023 §21.3.1: $fclose implicitly cancels active $fmonitor and
// $fstrobe operations on the descriptor it closes, and $fopen reuses closed
// channels. §21.3.2: $fmonitor and $fstrobe write to a file like $monitor
// and $strobe.
// Thirty files are opened with multichannel descriptors, which uses every
// channel (bits 1 to 30). $fmonitor on file mon writes when v changes at
// times 0 and 1. At time 2 an $fstrobe of v is scheduled on mon, mon is
// closed, and the next $fopen gets the channel of mon again, the only free
// one; v then changes at times 2 and 3. If the closing had not cancelled the
// monitor and the strobe, their lines for v = 3 and v = 4 would be written to
// the new file, which instead holds only its own line. Both files are read
// back with $fgets (§21.3.4.2). The test creates its files in the current
// directory.
// Neither simulator follows the clause here: Icarus Verilog 13.0 still
// writes the pending strobe line to the new file, and in release 5.052 of
// the Verilator tool both the monitor lines and the strobe line reach it.

module test_fclose_cancels_fmonitor_fstrobe;
  int fill [0:28];
  int mon, other;
  int v = 0;

  function automatic string chomp(string s);
    if (s.len() > 0 && s[s.len() - 1] == "\n") return s.substr(0, s.len() - 2);
    return s;
  endfunction

  task automatic show(string tag, string name);
    int rd;
    string t;
    rd = $fopen(name, "r");
    $write("%s:", tag);
    while ($fgets(t, rd) != 0) $write(" [%s]", chomp(t));
    $display;
    $fclose(rd);
  endtask

  initial begin
    for (int i = 0; i < 29; i++)
      fill[i] = $fopen($sformatf("test_fclose_cancels_fmonitor_fstrobe_fill%0d.txt", i));
    mon = $fopen("test_fclose_cancels_fmonitor_fstrobe_mon.txt");
    $fmonitor(mon, "mon v=%0d", v);
    v = 1;
    #1 v = 2;
    #1;
    $fstrobe(mon, "strobe v=%0d", v);
    $fclose(mon);
    other = $fopen("test_fclose_cancels_fmonitor_fstrobe_other.txt");
    $display("same channel: %0d", other == mon);
    $fdisplay(other, "other line");
    v = 3;
    #1 v = 4;
    #1;
    $fclose(other);
    for (int i = 0; i < 29; i++) $fclose(fill[i]);
    show("mon", "test_fclose_cancels_fmonitor_fstrobe_mon.txt");
    show("other", "test_fclose_cancels_fmonitor_fstrobe_other.txt");
  end
endmodule
