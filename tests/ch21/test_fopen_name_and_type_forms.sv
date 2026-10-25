/*
:name: test_fopen_name_and_type_forms
:description: the file name and the type of $fopen may be string literals, string variables or integral values holding the characters; without a type $fopen opens the file for writing and returns a multichannel descriptor, with a type a file descriptor, and $fclose closes either (IEEE 1800-2023 Section 21.3.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.1 21.3.2 21.3.4.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_fopen_name_and_type_forms.expected
*/
// IEEE 1800-2023 §21.3.1: the filename and the type of $fopen are each a
// string literal, a value of the string type or an integral value that holds
// the characters. Without a type the file is opened for writing and a
// multichannel descriptor is returned, a 32-bit value with one bit set and
// bit 31 clear (bit 0 is standard output); with a type a file descriptor is
// returned, a 32-bit value with bit 31 set. $fclose takes either kind.
// Three files are opened with type "w" given as a literal, a string variable
// and an 8-bit integral value, and named by a literal, a string variable and
// an integral value exactly as wide as the name; a fourth is opened without
// a type, by an integral name. Each gets one line with $fdisplay (§21.3.2)
// and is closed with $fclose, and is then read back with $fgets (§21.3.4.2)
// after opening it with "r" given in the other forms, or "rb" as a 16-bit
// value. The test creates its files in the current directory.

module test_fopen_name_and_type_forms;
  string sname = "test_fopen_name_and_type_forms_s.txt";
  string smode = "w";
  string srd = "r";
  logic [8*36-1:0] iname = "test_fopen_name_and_type_forms_i.txt";
  logic [8*36-1:0] mname = "test_fopen_name_and_type_forms_m.txt";
  logic [7:0] imode = "w";
  logic [7:0] ird = "r";
  logic [15:0] irb = "rb";
  int fd1, fd2, fd3, mcd;

  function automatic string chomp(string s);
    if (s.len() > 0 && s[s.len() - 1] == "\n") return s.substr(0, s.len() - 2);
    return s;
  endfunction

  task automatic show(string tag, int rd);
    string l;
    $write("%s:", tag);
    while ($fgets(l, rd) != 0) $write(" [%s]", chomp(l));
    $display;
    $fclose(rd);
  endtask

  initial begin
    fd1 = $fopen("test_fopen_name_and_type_forms_l.txt", "w");
    fd2 = $fopen(sname, smode);
    fd3 = $fopen(iname, imode);
    mcd = $fopen(mname);
    $display("fd bit31: %0d %0d %0d distinct=%0d", fd1[31], fd2[31], fd3[31],
             fd1 != fd2 && fd2 != fd3 && fd1 != fd3);
    $display("mcd bit31=%0d bit0=%0d ones=%0d", mcd[31], mcd[0], $countones(mcd));
    $fdisplay(fd1, "literal");
    $fdisplay(fd2, "string");
    $fdisplay(fd3, "integral");
    $fdisplay(mcd, "multichannel");
    $fclose(fd1);
    $fclose(fd2);
    $fclose(fd3);
    $fclose(mcd);
    show("l", $fopen("test_fopen_name_and_type_forms_l.txt", srd));
    show("s", $fopen(sname, ird));
    show("i", $fopen(iname, "r"));
    show("m", $fopen(mname, irb));
  end
endmodule
