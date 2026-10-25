/*
:name: test_fopen_mcd_channels_limit_and_reuse
:description: multichannel descriptors are one-hot with bit 0 for standard output and bit 31 always clear, so at most 30 files can be opened with them; OR-ing them writes to several files, $fclose of an OR closes all of them, and $fopen reuses the closed channels (IEEE 1800-2023 Section 21.3.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.1 21.3.2 21.3.4.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_fopen_mcd_channels_limit_and_reuse.expected
*/
// IEEE 1800-2023 §21.3.1: a multichannel descriptor (mcd) is a 32-bit value
// with a single bit set for the file; bit 0 always means standard output,
// and bit 31 is reserved and always clear, so at most 31 files, standard
// output among them, can be open through mcds. OR-ing mcds and writing to
// the result writes to all of their files. $fclose with an mcd closes every
// file whose bit is set, and $fopen reuses closed channels.
// The test opens 30 files without a type: each mcd has one bit set and
// neither bit 0 nor bit 31, they are all different, and together they are
// exactly the bits 1 to 30 (7ffffffe), whatever order a tool gives them
// in. A 31st file gets 0, as no channel is left. One $fdisplay to file 3 OR
// file 4 OR bit 0 prints on standard output and writes both files. After
// $fclose of file 6, the next $fopen gets the channel of file 6, the only
// free one; after one $fclose of file 1 OR file 2, the next two get those
// two channels, which shows that both files were closed. All 30 channels,
// now held by the old and the new files, are then closed by one $fclose,
// and files 1, 3 and 4 are read back with $fgets (§21.3.4.2).
// The test creates its files in the current directory.

module test_fopen_mcd_channels_limit_and_reuse;
  int m [0:29];
  int all, onehot, edge_bits, distinct, extra, n6, na, nb, fd;
  string l;

  function automatic string fname(int i);
    return $sformatf("test_fopen_mcd_channels_limit_and_reuse_%0d.txt", i);
  endfunction

  function automatic string chomp(string s);
    if (s.len() > 0 && s[s.len() - 1] == "\n") return s.substr(0, s.len() - 2);
    return s;
  endfunction

  task automatic show(int i);
    int rd;
    string t;
    rd = $fopen(fname(i), "r");
    $write("file %0d:", i);
    while ($fgets(t, rd) != 0) $write(" [%s]", chomp(t));
    $display;
    $fclose(rd);
  endtask

  initial begin
    all = 0;
    onehot = 1;
    edge_bits = 0;
    distinct = 1;
    for (int i = 0; i < 30; i++) begin
      m[i] = $fopen(fname(i));
      if ($countones(m[i]) != 1) onehot = 0;
      if (m[i][0] || m[i][31]) edge_bits = 1;
      if ((all & m[i]) != 0) distinct = 0;
      all |= m[i];
    end
    $display("onehot=%0d bit0_or_bit31=%0d distinct=%0d all=%h", onehot, edge_bits, distinct,
             all);
    extra = $fopen(fname(30));
    $display("31st=%h", extra);
    $fdisplay(m[1], "only one");
    $fdisplay(m[3] | m[4] | 1, "to three and four and stdout");
    $fclose(m[6]);
    n6 = $fopen(fname(31));
    $display("reuse of 6: %0d", n6 == m[6]);
    $fclose(m[1] | m[2]);
    na = $fopen(fname(32));
    nb = $fopen(fname(33));
    $display("reuse of 1 and 2: %0d", na != nb && (na | nb) == (m[1] | m[2]));
    $fdisplay(na | nb, "new file");
    $fclose(all);
    show(1);
    show(3);
    show(4);
  end
endmodule
