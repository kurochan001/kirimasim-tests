/*
:name: test_evcd_small_medium_large_strength_components
:description: An extended VCD checkpoint records small, medium and large as strength components 1, 2 and 4, on both low and high output ports (IEEE 1800-2023 Section 21.7.4.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.4.3 21.7.3.1 21.7.3.3 21.7.3.5 28.14 28.15.2
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_evcd_small_medium_large_strength_components.expected
*/
// Weak drive through one rtran becomes medium and through a second becomes
// small (28.14). A trireg (large) keeps its stored value with large charge
// strength when its bufif1 driver goes high impedance (28.15.2).
// The checkpoint at time 3 is after this release and includes every port
// (21.7.3.3). In extended VCD, small/medium/large have strength codes 1/2/4
// and high impedance has code 0 (21.7.4.3). A known 0 has the strength in
// its 0 component and highz in its 1 component; a known 1 has the reverse.
// Each strength therefore has both a low and a high port as a contrast.
// The reader associates actual $var reference names with their codes and
// reads the checkpoint, rather than assuming any particular code spelling.

`timescale 1ns/1ns
module evcd_capacitor_strength_dut(s0, s1, m0, m1, l0, l1);
  output s0, s1, m0, m1, l0, l1;
  wire s0, s1, m0, m1;
  trireg (large) l0, l1;
  wire weak_zero, weak_one;
  logic charge = 1'b1;
  assign (weak0, weak1) weak_zero = 1'b0;
  assign (weak0, weak1) weak_one = 1'b1;
  rtran medium_zero(weak_zero, m0);
  rtran medium_one(weak_one, m1);
  rtran small_zero(m0, s0);
  rtran small_one(m1, s1);
  bufif1 large_zero(l0, 1'b0, charge);
  bufif1 large_one(l1, 1'b1, charge);
  initial #2 charge = 1'b0;
endmodule

module test_evcd_small_medium_large_strength_components;
  wire s0, s1, m0, m1, l0, l1;
  evcd_capacitor_strength_dut dut(s0, s1, m0, m1, l0, l1);
  string names[6] = '{"s0", "s1", "m0", "m1", "l0", "l1"};
  string codes[6], strength_zero[6], strength_one[6];

  task automatic read_checkpoint;
    int fd, rc, time_value = -1;
    string token, typ, size, code, ref_name, zero, one, digits;
    bit checkpoint = 0;
    foreach (names[i]) begin
      codes[i] = "";
      strength_zero[i] = "missing";
      strength_one[i] = "missing";
    end
    fd = $fopen("test_evcd_small_medium_large_strength_components.evcd", "r");
    if (fd == 0) $fatal(1, "missing extended VCD file");
    while ($fscanf(fd, "%s", token) == 1) begin
      if (token == "$var") begin
        rc = $fscanf(fd, "%s %s %s %s", typ, size, code, ref_name);
        foreach (names[i]) if (ref_name == names[i]) codes[i] = code;
        do rc = $fscanf(fd, "%s", token); while (rc == 1 && token != "$end");
      end else if (token == "$dumpportsall") begin
        checkpoint = time_value == 3;
      end else if (token == "$end") begin
        checkpoint = 0;
      end else if (token[0] == "$" && token != "$dumpports" &&
                   token != "$dumpportson" && token != "$dumpportsoff") begin
        do rc = $fscanf(fd, "%s", token); while (rc == 1 && token != "$end");
      end else if (token[0] == "#") begin
        digits = token.substr(1, token.len() - 1);
        time_value = digits.atoi();
        checkpoint = 0;
      end else if (token.len() == 2 && token[0] == "p") begin
        rc = $fscanf(fd, "%s %s %s", zero, one, code);
        if (checkpoint && rc == 3)
          foreach (names[i]) if (code == codes[i] && codes[i] != "") begin
            strength_zero[i] = zero;
            strength_one[i] = one;
          end
      end
    end
    $fclose(fd);
    foreach (names[i])
      $display("%s strength0=%s strength1=%s", names[i],
               strength_zero[i], strength_one[i]);
  endtask

  initial begin
    $dumpports(dut, "test_evcd_small_medium_large_strength_components.evcd");
    #3 $dumpportsall("test_evcd_small_medium_large_strength_components.evcd");
    #1 $dumpportsflush("test_evcd_small_medium_large_strength_components.evcd");
    read_checkpoint;
  end
endmodule
