/*
:name: test_pattern_print_array_and_packed_struct
:description: %p prints an unpacked array as an assignment pattern, whose index labels are optional, and a packed structure as an assignment pattern with named elements (IEEE 1800-2023 Section 21.2.1.6)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_pattern_print_array_and_packed_struct.expected
*/
// IEEE 1800-2023 §21.2.1.6: for an unpacked array, %p prints the value as an
// assignment pattern, which may include index labels; for a packed structure
// it prints an assignment pattern with named elements, and each element is
// printed as it would print unformatted. White space is implementation
// dependent. The test removes white space and the optional index labels
// (digits followed by a colon directly after { or ,) so that only the values
// and the names are compared.
//
// The array holds 1, 2 and 3 in its three elements; the packed structure has
// hi = 4'hA and lo = 4'h5, whose unformatted values are 10 and 5.

module test_pattern_print_array_and_packed_struct;
  typedef struct packed {
    logic [3:0] hi;
    logic [3:0] lo;
  } pair_t;

  bit [3:0] arr[3] = '{4'h1, 4'h2, 4'h3};
  pair_t pk = '{hi: 4'hA, lo: 4'h5};

  function automatic string normalize(string text);
    string out = "";
    for (int i = 0; i < text.len(); i++) begin
      if (text[i] == " " || text[i] == "\t" || text[i] == "\n") continue;
      if (text[i] >= "0" && text[i] <= "9") begin
        int j = i;
        while (j < text.len() && text[j] >= "0" && text[j] <= "9") j++;
        if (j < text.len() && text[j] == ":") begin
          i = j;
          continue;
        end
      end
      out = {out, text.substr(i, i)};
    end
    return out;
  endfunction

  initial begin
    $display("array %s", normalize($sformatf("%p", arr)));
    $display("packed %s", normalize($sformatf("%p", pk)));
  end
endmodule
