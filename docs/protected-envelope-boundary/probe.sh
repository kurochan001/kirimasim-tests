#!/bin/sh
# Probes of how Icarus Verilog 13.0 and Verilator 5.052 treat IEEE 1800-2023
# clause 34 protected envelopes. Run it from an empty directory: it writes
# its inputs there. ICARUS_BIN is the directory holding iverilog and vvp.
# Usage: sh probe.sh > probe-log.txt 2>&1
IV=${ICARUS_BIN:?set ICARUS_BIN to the Icarus Verilog 13.0 bin directory}
B24=QUJDREVGR0hJSktMTU5PUFFSU1RVVldY

say() { echo; echo "==================== $* ===================="; }
ic() { echo "--- iverilog $1"; "$IV/iverilog" -g2012 -o /tmp/ch34_$1.vvp "$1" >/tmp/ch34_ic.out 2>&1; echo "compile=$?"; head -4 /tmp/ch34_ic.out; if [ -f /tmp/ch34_$1.vvp ]; then "$IV/vvp" /tmp/ch34_$1.vvp 2>&1 | head -5; rm -f /tmp/ch34_$1.vvp; fi; }
vl() { echo "--- verilator $1"; verilator --lint-only -Wno-fatal "$1" >/tmp/ch34_vl.out 2>&1; echo "exit=$?"; grep -E "Error|Warning" /tmp/ch34_vl.out | head -8; }

say "P0 tool versions"
"$IV/iverilog" -V 2>&1 | head -1
verilator --version
echo "iverilog -h protect/decrypt options:"; "$IV/iverilog" -h 2>&1 | grep -ci protect
echo "vvp -h protect/decrypt options:"; "$IV/vvp" -h 2>&1 | grep -ci protect
echo "verilator protect options:"; verilator --help 2>&1 | grep -E "protect" | head -5

say "P1 unknown protect keyword"
cat > p_unk.sv <<'EOF'
`pragma protect foo_bar
module p_unk; initial $display("ran"); endmodule
EOF
ic p_unk.sv; vl p_unk.sv

say "P2 empty begin_protected/end_protected"
cat > p_empty.sv <<'EOF'
module p_empty;
  `pragma protect begin_protected
  `pragma protect end_protected
  initial $display("ran");
endmodule
EOF
ic p_empty.sv; vl p_empty.sv

say "P3 cleartext module inside begin_protected: is it compiled?"
cat > p_clear.sv <<'EOF'
`pragma protect begin_protected
module p_secret; initial $display("SECRET RAN"); endmodule
`pragma protect end_protected
module p_clear; initial $display("wrapper ran"); endmodule
EOF
ic p_clear.sv; vl p_clear.sv

say "P4 data_block with base64 payload"
cat > p_data.sv <<EOF
\`pragma protect encoding=(enctype="base64", line_length=76, bytes=24)
\`pragma protect begin_protected
\`pragma protect data_block
$B24
\`pragma protect end_protected
module p_data; initial \$display("ran"); endmodule
EOF
ic p_data.sv; vl p_data.sv

say "P5 protect begin / protect end (encryption keywords)"
cat > p_begin.sv <<'EOF'
`pragma protect begin
module p_begin; initial $display("ran"); endmodule
`pragma protect end
EOF
ic p_begin.sv; vl p_begin.sv

say "P6 key_block and data_block in one envelope (encoding bytes=24)"
cat > p_keydata.sv <<EOF
\`pragma protect encoding=(enctype="base64", line_length=76, bytes=24)
\`pragma protect begin_protected
\`pragma protect key_block
$B24
\`pragma protect data_block
$B24
\`pragma protect end_protected
module p_keydata; initial \$display("ran"); endmodule
EOF
ic p_keydata.sv; vl p_keydata.sv

say "P7 encoding uuencode / quoted-printable / raw"
for e in uuencode quoted-printable raw; do
cat > p_enc.sv <<EOF
\`pragma protect encoding=(enctype="$e", line_length=76, bytes=24)
\`pragma protect begin_protected
\`pragma protect data_block
$B24
\`pragma protect end_protected
module p_enc; initial \$display("ran"); endmodule
EOF
echo "### enctype=$e"; vl p_enc.sv
done

say "P8 encoding line_length 50 (not a multiple of 4)"
cat > p_ll.sv <<EOF
\`pragma protect encoding=(enctype="base64", line_length=50, bytes=24)
\`pragma protect begin_protected
\`pragma protect data_block
$B24
\`pragma protect end_protected
module p_ll; initial \$display("ran"); endmodule
EOF
vl p_ll.sv

say "P9 digest_block"
cat > p_dig.sv <<'EOF'
`pragma protect begin_protected
`pragma protect digest_block
`pragma protect end_protected
module p_dig; initial $display("ran"); endmodule
EOF
ic p_dig.sv; vl p_dig.sv

say "P10 author / author_info / data_keyowner / data_keyname"
for kw in 'author="A"' 'author_info="I"' 'data_keyowner="O"' 'data_keyname="N"' 'data_method="aes256-cbc"' 'key_keyname="N"' 'encrypt_agent="E"'; do
cat > p_kw.sv <<EOF
\`pragma protect begin_protected
\`pragma protect $kw
\`pragma protect end_protected
module p_kw; initial \$display("ran"); endmodule
EOF
echo "### keyword $kw"; vl p_kw.sv
done

say "P11 eight nested empty envelopes"
{ for i in 1 2 3 4 5 6 7 8; do echo '`pragma protect begin_protected'; done
  for i in 1 2 3 4 5 6 7 8; do echo '`pragma protect end_protected'; done
  echo 'module p_nest; initial $display("ran"); endmodule'; } > p_nest.sv
ic p_nest.sv; vl p_nest.sv

say "P12 unmatched end_protected / unclosed begin_protected"
printf '`pragma protect end_protected\nmodule p_stray; initial $display("ran"); endmodule\n' > p_stray.sv
ic p_stray.sv; vl p_stray.sv
printf '`pragma protect begin_protected\nmodule p_open; initial $display("ran"); endmodule\n' > p_open.sv
ic p_open.sv; vl p_open.sv

say "P13 envelope crossing an include boundary"
mkdir -p inc
cat > inc/open.svh <<EOF
\`pragma protect begin_protected
\`pragma protect encoding=(enctype="base64", line_length=76, bytes=24)
\`pragma protect data_block
$B24
EOF
cat > p_inc.sv <<'EOF'
`include "inc/open.svh"
`pragma protect end_protected
module p_inc; initial $display("ran"); endmodule
EOF
echo "--- iverilog p_inc.sv"; "$IV/iverilog" -g2012 -Iinc -o /tmp/ch34_inc.vvp p_inc.sv 2>&1 | head -4
echo "--- verilator p_inc.sv"; verilator --lint-only -Wno-fatal -Iinc p_inc.sv 2>&1 | grep -E "Error|Warning" | head -4

say "P14 --protect-key does not decrypt an IEEE envelope"
verilator --lint-only -Wno-fatal --protect-key 0123456789abcdef0123456789abcdef p_data.sv 2>&1 | grep -E "Error|Warning" | head -4

say "P15 module defined inside a data_block is not available"
cat > p_mod.sv <<EOF
\`pragma protect encoding=(enctype="base64", line_length=76, bytes=24)
\`pragma protect begin_protected
\`pragma protect data_block
$B24
\`pragma protect end_protected
module p_use; p_absent u(); initial \$display("ran"); endmodule
EOF
vl p_mod.sv

say "P16 data_block payload on the same line"
cat > p_same.sv <<EOF
\`pragma protect begin_protected
\`pragma protect data_block $B24
\`pragma protect end_protected
module p_same; initial \$display("ran"); endmodule
EOF
ic p_same.sv; vl p_same.sv

say "P17 text between begin_protected and end_protected still executes"
cat > p_inner.sv <<'EOF'
module p_inner;
  initial begin
    $display("before");
`pragma protect begin_protected
    $display("inside");
`pragma protect end_protected
    $display("after");
  end
endmodule
EOF
ic p_inner.sv
echo "--- verilator --binary p_inner.sv"
verilator --binary --timing -Wno-fatal -Wno-lint -Wno-style -o /tmp/Vch34 p_inner.sv --top-module p_inner >/tmp/ch34_build.log 2>&1
echo "build=$?"; grep -E "PROTECTED|Error" /tmp/ch34_build.log | head -3
/tmp/Vch34 2>&1 | head -5

say "P18 legacy `protected / `endprotected form"
printf '`protected\nQUJDREVGR0hJSktM\n`endprotected\nmodule p_legacy; initial $display("ran"); endmodule\n' > p_legacy.sv
ic p_legacy.sv; vl p_legacy.sv

say "P19 which Table 34-1 keywords Verilator recognizes"
for kw in 'begin' 'end' 'begin_protected' 'end_protected' 'author="A"' 'author_info="I"' \
          'encrypt_agent="E"' 'encrypt_agent_info="EI"' \
          'encoding=(enctype="base64", line_length=76, bytes=12)' 'data_keyowner="O"' \
          'data_method="aes256-cbc"' 'data_keyname="N"' 'data_public_key' \
          'data_decrypt_key' 'data_block' 'digest_keyowner="O"' 'digest_key_method="md5"' \
          'digest_keyname="N"' 'digest_public_key' 'digest_decrypt_key' 'digest_method="sha1"' \
          'digest_block' 'key_keyowner="O"' 'key_method="rsa"' 'key_keyname="N"' \
          'key_public_key' 'key_block' 'decrypt_license=(library="l", entry="e", feature="f")' \
          'runtime_license=(library="l", entry="e", feature="f")' 'comment="C"' 'reset' \
          'viewport=(object="o", access="read")' 'version=1'; do
  { echo '`pragma protect begin_protected'; echo "\`pragma protect $kw"; echo '`pragma protect end_protected'; echo 'module kwm; initial $display("ran"); endmodule'; } > p_kw.sv
  verilator --lint-only -Wno-fatal p_kw.sv >/tmp/ch34_kw.out 2>&1
  if grep -q "Unknown '\`pragma protect' error" /tmp/ch34_kw.out; then r=unknown; else r=accepted; fi
  echo "$r  $kw"
done

say "P20 second encoding directive before the data_block"
cat > p_twoenc.sv <<EOF
\`pragma protect encoding=(enctype="base64", line_length=76, bytes=12)
\`pragma protect encoding=(enctype="base64", line_length=76, bytes=12)
\`pragma protect begin_protected
\`pragma protect data_block
QUJDREVGR0hJSktM
\`pragma protect end_protected
module p_twoenc; initial \$display("ran"); endmodule
EOF
vl p_twoenc.sv
