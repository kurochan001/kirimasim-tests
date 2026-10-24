/*
:name: test_evcd_port_states_strengths_and_controls
:description: $dumpports writes an extended VCD file in which each value change of a scalar port is p, a state character (D, U, N, Z for an input, L, H, X, T for an output), the strength0 and strength1 components and the identifier code of the port; $dumpportsoff writes an x checkpoint and stops the dump, $dumpportson dumps the current values and resumes it, a repeated call of either and a call that names another file are ignored, and $dumpportsall writes every value (IEEE 1800-2023 Sections 21.7.3.2, 21.7.3.3, 21.7.3.7 and 21.7.4.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.3.2 21.7.3.3 21.7.3.5 21.7.3.7 21.7.4.3 21.7.4.3.1 21.7.3.1 21.7.4.1 21.7.4.2 21.7.4 21.7
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_evcd_port_states_strengths_and_controls.expected
*/
// IEEE 1800-2023 §21.7.3.1: $dumpports names the module whose ports are
// dumped and the file, and the dump starts at the end of the current time
// step, so the pulse of v_y within time 0 after the call is not dumped and
// the first values are those at the end of time 0. §21.7.4.1 and
// §21.7.4.3: after the declarations, each value change of a port is the
// key character p, without a space, a state character,
// the strength0 and the strength1 component, and the identifier code <n of
// the port, under #time in absolute simulation time. §21.7.4.3.1: an input
// (driven by the test fixture) is D low, U high, N unknown or Z three-state,
// an output (driven by the device) L, H, X or T. The strength components
// are 0 highz, 3 weak, 5 pull, 6 strong and 7 supply; as in the example of
// §21.7.4.4, a 0 has the strength of its driver as strength0 and highz as
// strength1, a 1 the reverse, an x driven by a strong driver strong for
// both, and a z highz for both. §21.7.4.2: the ports are $var port of size
// 1 with the codes <0 to <5 in the order of the module declaration.
// The inputs of evcd_dut are driven by continuous assignments of strong,
// weak, pull and supply strength; its outputs by a strong and a weak
// continuous assignment of internal variables. Only the ports that change
// at a time step are listed (§21.7.4.1).
// §21.7.3.2: $dumpportsoff writes a checkpoint in which each port has an x
// value (N for an input, X for an output; the strengths of that checkpoint
// are not given by the clause and are not printed) and stops the dump, so
// the change of i_s at 55 is not dumped; $dumpportson writes the values of
// all ports and resumes it; a $dumpportsoff while the dump is suspended
// (57) and a $dumpportson while it runs (62) are ignored. §21.7.3.7: a
// control task that names a file that no $dumpports opened is ignored, so
// the $dumpportsoff at 65 does not stop the dump and the change at 70 is
// written. §21.7.3.3: $dumpportsall writes the values of all ports at 80,
// changed or not. The file names are given as a string localparam or as a
// string literal. §21.7.3.5: $dumpportsflush writes the buffered values to
// the file, which the test then reads token by token, white space
// separating them (§21.7.4). It prints the declarations, then the values
// at each time and in each section, sorted by identifier code, and counts
// the tokens that are not a command, a time or a port value change.
// No release of Icarus Verilog 13.0 or Verilator 5.052 implements
// $dumpports, so the expected output comes from the clauses alone.

`timescale 1ns / 1ns

module evcd_dut(input wire i_s, input wire i_w, input wire i_p, input wire i_y,
                output wire o_s, output wire o_w);
  logic r_s = 1'b0, r_w = 1'b0;
  assign o_s = r_s;
  assign (weak0, weak1) o_w = r_w;
endmodule

module test_evcd_port_states_strengths_and_controls;
  localparam string FILE = "test_evcd_port_states_strengths_and_controls.evcd";
  logic v_s = 1'b0, v_w = 1'b0, v_p = 1'b0, v_y = 1'b0;
  wire n_s, n_w, n_p, n_y, o_s, o_w;
  string names[$], codes[$], vals[$];

  assign n_s = v_s;
  assign (weak0, weak1) n_w = v_w;
  assign (pull0, pull1) n_p = v_p;
  assign (supply0, supply1) n_y = v_y;

  evcd_dut dut(.i_s(n_s), .i_w(n_w), .i_p(n_p), .i_y(n_y), .o_s(o_s), .o_w(o_w));

  function automatic int find(string code);
    foreach (codes[k]) if (codes[k] == code) return k;
    return -1;
  endfunction

  function automatic int code_number(string code);
    string digits = code.substr(1, code.len() - 1);
    return digits.atoi();
  endfunction

  // Prints the values collected for one time or section, by identifier code.
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

  task automatic read(string file);
    int fd, k, t = 0, malformed = 0;
    string tok, typ, size, code, ref_name, s0, s1, section = "";
    bit defs = 0, date_seen = 0, version_seen = 0, scale_seen = 0;
    fd = $fopen(file, "r");
    while ($fscanf(fd, "%s", tok) == 1) begin
      if (tok == "$var") begin
        defs = 1;
        void'($fscanf(fd, "%s %s", typ, size));
        while (size.substr(0, 0) == "[" && size.substr(size.len() - 1, size.len() - 1) != "]")
          if ($fscanf(fd, "%s", tok) == 1) size = {size, tok};
        void'($fscanf(fd, "%s %s", code, ref_name));
        names.push_back(ref_name);
        codes.push_back(code);
        vals.push_back("");
        $display("var %0s %0s %0s %0s", typ, size, code, ref_name);
        do void'($fscanf(fd, "%s", tok)); while (tok != "$end");
      end else if (tok == "$date" || tok == "$version" || tok == "$timescale") begin
        if (!defs && tok == "$date") date_seen = 1;
        if (!defs && tok == "$version") version_seen = 1;
        if (!defs && tok == "$timescale") scale_seen = 1;
        do void'($fscanf(fd, "%s", tok)); while (tok != "$end");
      end else if (tok == "$scope" || tok == "$upscope" || tok == "$comment" ||
                   tok == "$enddefinitions" || tok == "$vcdclose") begin
        if (tok == "$scope") begin
          if (!defs)
            $display("before the first scope: $date %0s, $version %0s, $timescale %0s",
                     date_seen ? "yes" : "no", version_seen ? "yes" : "no",
                     scale_seen ? "yes" : "no");
          defs = 1;
        end
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
    $dumpports(test_evcd_port_states_strengths_and_controls.dut, FILE);
    v_y = 1'b1;
    #0 v_y = 1'b0;
    #10 v_s = 1'b1; v_w = 1'b1;
    #10 v_s = 1'bx; v_p = 1'b1; dut.r_s = 1'b1;
    #10 v_s = 1'bz; v_y = 1'b1; dut.r_s = 1'bx; dut.r_w = 1'b1;
    #10 dut.r_s = 1'bz;
    #10 $dumpportsoff(FILE);
    #5 v_s = 1'b0;
    #2 $dumpportsoff(FILE);
    #3 $dumpportson(FILE);
    #2 $dumpportson("test_evcd_port_states_strengths_and_controls.evcd");
    #3 $dumpportsoff("test_evcd_port_states_no_such_file.evcd");
    #5 v_w = 1'b0;
    #10 $dumpportsall("test_evcd_port_states_strengths_and_controls.evcd");
    #5 $dumpportsflush("test_evcd_port_states_strengths_and_controls.evcd");
    #5 $dumpportsflush(FILE);
    read(FILE);
  end
endmodule
