/*
:name: test_evcd_inout_output_strong_and_unknown_direction
:description: When the device drives an inout port strongly and the test fixture weakly with the same value, the extended VCD state is l or h with the strength of the output, and when the two directions drive different values the state is A, a, B, b, C or c according to the input and output values; an inout port driven only from inside is H (IEEE 1800-2023 Sections 21.7.4.3.1 and 21.7.4.3.2)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.4.3.1 21.7.4.3.2 21.7.4.3 21.7.4.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_evcd_inout_output_strong_and_unknown_direction.expected
*/
// IEEE 1800-2023 §21.7.4.3.2: the input of a port is driven by the test
// fixture, outside the module, and the output by the device, inside it;
// gate primitives count as drivers as well as continuous assignments. When
// the input drives a weak strength and the output a strong strength (7 to
// 5) of the same value, the state is l or h (§21.7.4.3.1: low or high with
// two drivers active) with the strength of the output. §21.7.4.3.1: when the
// two directions drive different values, the unknown direction states give
// the pair: A input 0 and output 1, a input 0 and output X, B input 1 and
// output 0, b input 1 and output X, C input X and output 0, c input X and
// output 1. Each inout port of evcd_dir_dut has one constant driver inside
// and the net it is connected to one outside: l0 weak 0 outside and the
// strong 0 of a buf primitive inside, h1 weak 1 outside and strong 1 inside,
// and for ca, cb, xa, xb, xc and xcc strong drivers of the values of each
// pair; out1 has only a strong 1 inside, which is the output state H. The
// strength components follow §21.7.4.3 (0 highz, 6 strong); the clauses do
// not give them for the unknown direction states, whose strengths are not
// printed. The test reads the file after $dumpportsflush and prints the
// values of the $dumpports section at time 0, sorted by identifier code.
// No release of Icarus Verilog 13.0 or Verilator 5.052 implements
// $dumpports, so the expected output comes from the clauses alone.

`timescale 1ns / 1ns

module evcd_dir_dut(inout wire l0, inout wire h1, inout wire ca, inout wire xa,
                    inout wire cb, inout wire xb, inout wire xc, inout wire xcc,
                    inout wire out1);
  buf g_l0(l0, 1'b0);
  assign h1 = 1'b1;
  assign ca = 1'b1;
  assign xa = 1'bx;
  assign cb = 1'b0;
  assign xb = 1'bx;
  assign xc = 1'b0;
  assign xcc = 1'b1;
  assign out1 = 1'b1;
endmodule

module test_evcd_inout_output_strong_and_unknown_direction;
  localparam string FILE = "test_evcd_inout_output_strong_and_unknown_direction.evcd";
  wire n_l0, n_h1, n_ca, n_xa, n_cb, n_xb, n_xc, n_xcc, n_out1;
  string names[$], codes[$], vals[$];

  assign (weak0, weak1) n_l0 = 1'b0;
  assign (weak0, weak1) n_h1 = 1'b1;
  assign n_ca = 1'b0;
  assign n_xa = 1'b0;
  assign n_cb = 1'b1;
  assign n_xb = 1'b1;
  assign n_xc = 1'bx;
  assign n_xcc = 1'bx;
  evcd_dir_dut dut(.l0(n_l0), .h1(n_h1), .ca(n_ca), .xa(n_xa), .cb(n_cb), .xb(n_xb),
                   .xc(n_xc), .xcc(n_xcc), .out1(n_out1));

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
        else if (section == "$dumpportsoff" || tok[1] == "A" || tok[1] == "a" ||
                 tok[1] == "B" || tok[1] == "b" || tok[1] == "C" || tok[1] == "c")
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
    $dumpports(test_evcd_inout_output_strong_and_unknown_direction.dut, FILE);
    #10 $dumpportsflush(FILE);
    read_ports(FILE);
  end
endmodule
