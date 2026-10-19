/*
:name: test_vcd_dump_readback
:description: $dumpvars with a level of 1 dumps the variables of the given module but not those of its instances or its unpacked arrays; the VCD file lists their values in the $dumpvars section and then each change under its time, $dumpoff dumps every variable as x and stops dumping, $dumpon dumps the current values, and $dumpall makes a checkpoint (IEEE 1800-2023 Section 21.7)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.1.1 21.7.1.2 21.7.1.3 21.7.1.4 21.7.1.6 21.7.2.1 21.7.2.2 21.7.2.3 21.7.5
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_vcd_dump_readback.expected
*/
// IEEE 1800-2023 §21.7.1.1: $dumpfile names the VCD file. §21.7.1.2:
// $dumpvars(1, m) dumps the variables of module m only, not of the instances
// below it. §21.7.1.3: dumping starts at the end of the time step; $dumpoff
// dumps every variable as x and stops dumping; $dumpon dumps the current
// values. §21.7.1.4: $dumpall dumps the current values. §21.7.1.6:
// $dumpflush writes out the buffered data. §21.7.2.1 to §21.7.2.3: $var gives
// the type, size, identifier code and name of a variable, #time the time of
// the changes that follow in units of $timescale, and the $dumpvars,
// $dumpoff, $dumpon and $dumpall sections list values; a scalar is a value
// and the code, a vector b, its shortest digits (§21.7.2.2), a space and the
// code. §21.7.5: logic is dumped as reg and int as integer of size 32, and
// unpacked arrays are not dumped. The reader module, an instance that is not
// dumped, reads the file back by tokens, replaces the identifier codes by
// the names and prints the values at each time in ns and then the variables,
// sorted by name; the header sections such as $date and $version, which
// differ between tools, are skipped.

`timescale 1ns/1ns

module vcd_child;
  logic [3:0] cnt = 0;
  initial #15 cnt = 7;
endmodule

module vcd_reader;
  string name_of[string];
  string kind_of[string];
  string vals[string];

  // Prints the values collected for one time or section, sorted by name.
  task automatic flush(real t, string section);
    string line;
    if (vals.num() == 0) return;
    line = $sformatf("%0d%s:", longint'(t), section == "" ? "" : {" ", section});
    foreach (vals[name]) line = {line, " ", name, "=", vals[name]};
    $display("%s", line);
    vals.delete();
  endtask

  // The size of a $timescale unit in ns.
  function automatic real unit_ns(string u);
    case (u)
      "s": return 1e9;
      "ms": return 1e6;
      "us": return 1e3;
      "ns": return 1.0;
      "ps": return 1e-3;
      default: return 1e-6;
    endcase
  endfunction

  task automatic read(string file);
    int fd = $fopen(file, "r");
    string tok, id, rest, section = "", scale = "";
    real step = 1.0, t = 0.0;
    int num;
    while ($fscanf(fd, "%s", tok) == 1) begin
      rest = tok.substr(1, tok.len() - 1);
      if (tok == "$var") begin
        string typ, size, code, ref_name;
        void'($fscanf(fd, "%s %s %s %s", typ, size, code, ref_name));
        name_of[code] = ref_name;
        kind_of[ref_name] = {typ, " ", size};
        do void'($fscanf(fd, "%s", tok)); while (tok != "$end");
      end else if (tok == "$timescale") begin
        do begin
          void'($fscanf(fd, "%s", tok));
          if (tok != "$end") scale = {scale, tok};
        end while (tok != "$end");
        num = scale.atoi();
        step = num * unit_ns(scale.substr(num >= 100 ? 3 : num >= 10 ? 2 : 1, scale.len() - 1));
      end else if (tok inside {"$scope", "$upscope", "$date", "$version", "$comment",
                               "$enddefinitions"}) begin
        do void'($fscanf(fd, "%s", tok)); while (tok != "$end");
      end else if (tok[0] == "#") begin
        flush(t, section);
        t = rest.atoi() * step;
      end else if (tok inside {"$dumpvars", "$dumpoff", "$dumpon", "$dumpall"}) begin
        flush(t, section);
        section = tok;
      end else if (tok == "$end") begin
        flush(t, section);
        section = "";
      end else if (tok[0] inside {"b", "B", "r", "R"}) begin
        void'($fscanf(fd, "%s", id));
        vals[name_of.exists(id) ? name_of[id] : "?"] = rest.tolower();
      end else begin
        vals[name_of.exists(rest) ? name_of[rest] : "?"] = tok.substr(0, 0).tolower();
      end
    end
    flush(t, section);
    $fclose(fd);
    foreach (kind_of[name]) $display("var %s: %s", name, kind_of[name]);
  endtask
endmodule

module test_vcd_dump_readback;
  logic a = 0;
  logic [3:0] v = 4'b0010;
  int n = 5;
  logic [1:0] mem [0:1];

  vcd_child u();
  vcd_reader r();

  initial begin
    $dumpfile("test_vcd_dump_readback.vcd");
    $dumpvars(1, test_vcd_dump_readback);
    #10 a = 1; v = 4'b10x1; mem[0] = 2'b11;
    #10 $dumpoff;
    #10 a = 0;
    #10 $dumpon;
    #10 v = 4'b0001;
    #10 $dumpall;
    #1 $dumpflush;
    r.read("test_vcd_dump_readback.vcd");
  end
endmodule
