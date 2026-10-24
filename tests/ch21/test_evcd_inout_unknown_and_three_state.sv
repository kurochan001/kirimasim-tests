/*
:name: test_evcd_inout_unknown_and_three_state
:description: An inout port whose test fixture and device both drive x has the extended VCD state ?, one with no driver on either side the state F, and one whose drivers on both sides are three-stated the state f, while an input or output port driven only to z is Z or T (IEEE 1800-2023 Section 21.7.4.3.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.4.3.1 21.7.4.1 21.7.4.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_evcd_inout_unknown_and_three_state.expected
*/
// IEEE 1800-2023 §21.7.4.3.1: the states of unknown direction include ?
// (unknown), F (three-state, input and output unconnected) and f (unknown,
// input and output three-stated), next to the pairs of input and output
// values that A, a, B, b, C and c name; the input is driven by the test
// fixture, outside the module, and the output by the device, inside it
// (21.7.4.3.2). The inout port qq of evcd_unk_dut is driven to x by a
// strong continuous assignment on both sides, a pair of unknowns that no
// other state names; ff is left unconnected outside and has no driver
// inside; tf has a driver on each side, both driving z. For contrast, the
// input zi is driven only to z from outside and the output zo only to z
// from inside, the states Z and T.
// The clauses do not give the strength components of ?, F and f, so only
// their state characters are printed; Z and T have highz (0) for both, as
// f has in the example of §21.7.4.4. The test reads the file after
// $dumpportsflush and prints the values of the $dumpports section at time
// 0, sorted by identifier code.
// No release of Icarus Verilog 13.0 or Verilator 5.052 implements
// $dumpports, so the expected output comes from the clauses alone.

`timescale 1ns / 1ns

module evcd_unk_dut(inout wire qq, inout wire ff, inout wire tf, input wire zi,
                    output wire zo);
  assign qq = 1'bx;
  assign tf = 1'bz;
  assign zo = 1'bz;
endmodule

module test_evcd_inout_unknown_and_three_state;
  localparam string FILE = "test_evcd_inout_unknown_and_three_state.evcd";
  wire n_qq, n_tf, n_zi, n_zo;
  string names[$], codes[$], vals[$];

  assign n_qq = 1'bx;
  assign n_tf = 1'bz;
  assign n_zi = 1'bz;

  evcd_unk_dut dut(.qq(n_qq), .ff(), .tf(n_tf), .zi(n_zi), .zo(n_zo));

  function automatic int find(string code);
    foreach (codes[k]) if (codes[k] == code) return k;
    return -1;
  endfunction

  function automatic int code_number(string code);
    string digits = code.substr(1, code.len() - 1);
    return digits.atoi();
  endfunction

  task automatic flush(int t, string section);
    string line;
    bit any = 0;
    line = $sformatf("#%0d", t);
    if (section != "") line = {line, " ", section};
    line = {line, ":"};
    for (int n = 0; n < codes.size(); n++)
      foreach (codes[k])
        if (code_number(codes[k]) == n && vals[k] != "") begin
          line = {line, " ", names[k], "=", vals[k]};
          vals[k] = "";
          any = 1;
        end
    if (any) $display("%s", line);
  endtask

  task automatic read_ports(string file);
    int fd, k, t = 0, malformed = 0;
    string tok, typ, size, code, ref_name, s0, s1, section = "";
    fd = $fopen(file, "r");
    while ($fscanf(fd, "%s", tok) == 1) begin
      if (tok == "$var") begin
        void'($fscanf(fd, "%s %s %s %s", typ, size, code, ref_name));
        names.push_back(ref_name);
        codes.push_back(code);
        vals.push_back("");
        $display("var %0s %0s %0s %0s", typ, size, code, ref_name);
        do void'($fscanf(fd, "%s", tok)); while (tok != "$end");
      end else if (tok == "$date" || tok == "$version" || tok == "$timescale" ||
                   tok == "$scope" || tok == "$upscope" || tok == "$comment" ||
                   tok == "$enddefinitions" || tok == "$vcdclose") begin
        do void'($fscanf(fd, "%s", tok)); while (tok != "$end");
      end else if (tok.substr(0, 0) == "#" && tok.len() > 1) begin
        flush(t, section);
        tok = tok.substr(1, tok.len() - 1);
        t = tok.atoi();
      end else if (tok == "$dumpports" || tok == "$dumpportsoff" || tok == "$dumpportson" ||
                   tok == "$dumpportsall") begin
        flush(t, section);
        section = tok;
      end else if (tok == "$end") begin
        flush(t, section);
        section = "";
      end else if (tok.len() == 2 && tok.substr(0, 0) == "p") begin
        void'($fscanf(fd, "%s %s %s", s0, s1, code));
        k = find(code);
        if (k < 0) malformed++;
        else if (section == "$dumpportsoff" || tok[1] == "?" || tok[1] == "F" || tok[1] == "f")
          vals[k] = tok.substr(1, 1);
        else vals[k] = {tok, " ", s0, " ", s1};
      end else begin
        malformed++;
      end
    end
    flush(t, section);
    $fclose(fd);
    $display("tokens that are not a command, a time or a port value change: %0d", malformed);
  endtask

  initial begin
    $dumpports(test_evcd_inout_unknown_and_three_state.dut, FILE);
    #10 $dumpportsflush(FILE);
    read_ports(FILE);
  end
endmodule
