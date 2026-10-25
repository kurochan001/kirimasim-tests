/*
:name: test_writemem_dynamic_array_no_addresses
:description: $writememh and $writememb write a dynamic array without @ address words, and the file reads back with $readmemh and $readmemb (IEEE 1800-2023 Section 21.5.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.5.3 21.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_writemem_dynamic_array_no_addresses.expected
*/
// IEEE 1800-2023 §21.5.3: when $writememb and $writememh write the data of an
// unpacked or a dynamic array, no address specifiers (@ words) are written.
// The layout of the file is otherwise not fixed, so the test counts the @
// characters in each file and reads the data back into an unpacked array
// (21.5). The files are created in the current directory. Icarus Verilog 13.0
// and the 5.052 release of Verilator do not accept a dynamic array as the
// memory of $writememh and $writememb.

module test_writemem_dynamic_array_no_addresses;
  logic [7:0] d[];
  logic [2:0] e[];
  logic [7:0] back [0:2];
  logic [2:0] bits_back [0:1];

  function automatic int count_at(string name);
    int f = $fopen(name, "r");
    int n = 0;
    for (int c = $fgetc(f); c != -1; c = $fgetc(f)) if (c == "@") n++;
    $fclose(f);
    return n;
  endfunction

  initial begin
    d = new[3];
    d = '{8'h5a, 8'h00, 8'hc3};
    $writememh("test_writemem_dynamic_h.mem", d);
    $readmemh("test_writemem_dynamic_h.mem", back);
    $display("hex: @=%0d back=%h %h %h", count_at("test_writemem_dynamic_h.mem"), back[0],
             back[1], back[2]);
    e = new[2];
    e = '{3'b101, 3'b010};
    $writememb("test_writemem_dynamic_b.mem", e);
    $readmemb("test_writemem_dynamic_b.mem", bits_back);
    $display("binary: @=%0d back=%b %b", count_at("test_writemem_dynamic_b.mem"), bits_back[0],
             bits_back[1]);
  end
endmodule
