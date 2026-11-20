/*
:name: test_evcd_explicit_port_range_from_internal_net
:description: Extended VCD records a vector range from an explicit port's internal net when the port has no range, a range from an ordinary port declaration, and size 1 for a scalar (IEEE 1800-2023 Section 21.7.4.2)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.4.2 21.7.3.1 21.7.3.5 23.2.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_evcd_explicit_port_range_from_internal_net.expected
*/
// An explicit ANSI port has the self-determined type of its expression
// (23.2.2.2). The explicit .by_net(by_net) has no vector index in the port
// declaration and refers to a net declared [7:4] in the body. The ordinary
// port by_port has [0:3] in its declaration, and scalar has no range.
// For extended VCD these select the internal net's [7:4], the port's [0:3],
// and scalar size 1 respectively (21.7.4.2). The reader prints the range
// for each actual reference name, allowing whitespace in vector indices.

`timescale 1ns/1ns
module evcd_explicit_range_dut(output .by_net(by_net),
                               output wire [0:3] by_port,
                               output wire scalar);
  wire [7:4] by_net;
  assign by_net = 4'b1010;
  assign by_port = 4'b0101;
  assign scalar = 1'b1;
endmodule

module test_evcd_explicit_port_range_from_internal_net;
  wire [7:4] a;
  wire [0:3] b;
  wire c;
  evcd_explicit_range_dut dut(.by_net(a), .by_port(b), .scalar(c));
  string names[3] = '{"by_net", "by_port", "scalar"};
  string sizes[3];

  task automatic read_declarations;
    int fd, rc;
    string token, typ, size, code, ref_name;
    foreach (sizes[i]) sizes[i] = "missing";
    fd = $fopen("test_evcd_explicit_port_range_from_internal_net.evcd", "r");
    if (fd == 0) $fatal(1, "missing extended VCD file");
    while ($fscanf(fd, "%s", token) == 1 && token != "$enddefinitions") begin
      if (token == "$var") begin
        rc = $fscanf(fd, "%s %s", typ, size);
        while (rc == 2 && size[0] == "[" && size[size.len() - 1] != "]") begin
          if ($fscanf(fd, "%s", token) != 1) break;
          size = {size, token};
        end
        rc = $fscanf(fd, "%s %s", code, ref_name);
        if (rc == 2 && typ == "port")
          foreach (names[i]) if (ref_name == names[i]) sizes[i] = size;
        do rc = $fscanf(fd, "%s", token); while (rc == 1 && token != "$end");
      end else if (token[0] == "$") begin
        do rc = $fscanf(fd, "%s", token); while (rc == 1 && token != "$end");
      end
    end
    $fclose(fd);
    foreach (names[i]) $display("%s size=%s", names[i], sizes[i]);
  endtask

  initial begin
    $dumpports(dut, "test_evcd_explicit_port_range_from_internal_net.evcd");
    #1 $dumpportsflush("test_evcd_explicit_port_range_from_internal_net.evcd");
    read_declarations;
  end
endmodule
