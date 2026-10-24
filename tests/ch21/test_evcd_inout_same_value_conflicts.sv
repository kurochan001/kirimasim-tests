/*
:name: test_evcd_inout_same_value_conflicts
:description: When the test fixture and the device both drive an inout port with the same value, the extended VCD state is 0 or 1 with the stronger strength if both strengths are in the same range (5 to 7 strong, 1 to 4 weak), and d or u with the strength of the input if only the input is strong; an inout port driven only from outside is D (IEEE 1800-2023 Sections 21.7.4.3.1 and 21.7.4.3.2)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.4.3.1 21.7.4.3.2 21.7.4.3 21.7.4.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_evcd_inout_same_value_conflicts.expected
*/
// IEEE 1800-2023 §21.7.4.3.2: for the extended VCD, the drivers of a port
// are primitives, continuous assignments and procedural continuous
// assignments; the input is driven by the test fixture, outside the module,
// and the output by the device, inside it. Strengths 7 to 5 (supply, strong,
// pull) are the strong range and 4 to 1 the weak range. When input and
// output drive the same value with strengths of the same range, the state
// is the conflict state 0 or 1 (§21.7.4.3.1: both directions active) and
// the strength is the stronger of the two; when the input is strong and the
// output weak, the state is d or u (low or high with two drivers active)
// with the strength of the input. Each inout port of evcd_same_dut has one
// constant continuous assignment inside and the net it is connected to one
// outside: s0 strong 0 and strong 0, s1 supply 1 outside and strong 1
// inside, w0 weak 0 on both sides, q0 pull 0 outside and strong 0 inside
// (pull is in the strong range), d0 strong 0 outside and weak 0 inside, u1
// strong 1 outside and weak 1 inside, and in0 only a strong 0 outside, which
// is the input state D. The strength components follow §21.7.4.3 (0 highz,
// 3 weak, 6 strong, 7 supply), with highz for the side of the value that is
// not driven, as in the example of §21.7.4.4. The test reads the file after
// $dumpportsflush and prints the values of the $dumpports section at time
// 0, sorted by identifier code.
// No release of Icarus Verilog 13.0 or Verilator 5.052 implements
// $dumpports, so the expected output comes from the clauses alone.

`timescale 1ns / 1ns

module evcd_same_dut(inout wire s0, inout wire s1, inout wire w0, inout wire q0,
                     inout wire d0, inout wire u1, inout wire in0);
  assign s0 = 1'b0;
  assign s1 = 1'b1;
  assign (weak0, weak1) w0 = 1'b0;
  assign q0 = 1'b0;
  assign (weak0, weak1) d0 = 1'b0;
  assign (weak0, weak1) u1 = 1'b1;
endmodule

module test_evcd_inout_same_value_conflicts;
  localparam string FILE = "test_evcd_inout_same_value_conflicts.evcd";
  wire n_s0, n_s1, n_w0, n_q0, n_d0, n_u1, n_in0;
  string names[$], codes[$], vals[$];

  assign n_s0 = 1'b0;
  assign (supply0, supply1) n_s1 = 1'b1;
  assign (weak0, weak1) n_w0 = 1'b0;
  assign (pull0, pull1) n_q0 = 1'b0;
  assign n_d0 = 1'b0;
  assign n_u1 = 1'b1;
  assign n_in0 = 1'b0;
  evcd_same_dut dut(.s0(n_s0), .s1(n_s1), .w0(n_w0), .q0(n_q0), .d0(n_d0), .u1(n_u1),
                    .in0(n_in0));

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
        else if (section == "$dumpportsoff") vals[k] = tok.substr(1, 1);
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
    $dumpports(test_evcd_inout_same_value_conflicts.dut, FILE);
    #10 $dumpportsflush(FILE);
    read_ports(FILE);
  end
endmodule
