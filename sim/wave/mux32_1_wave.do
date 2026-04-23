onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mux32_1_tb/i
add wave -noupdate -radix hexadecimal -childformat {{{/mux32_1_tb/in[31]} -radix hexadecimal} {{/mux32_1_tb/in[30]} -radix hexadecimal} {{/mux32_1_tb/in[29]} -radix hexadecimal} {{/mux32_1_tb/in[28]} -radix hexadecimal} {{/mux32_1_tb/in[27]} -radix hexadecimal} {{/mux32_1_tb/in[26]} -radix hexadecimal} {{/mux32_1_tb/in[25]} -radix hexadecimal} {{/mux32_1_tb/in[24]} -radix hexadecimal} {{/mux32_1_tb/in[23]} -radix hexadecimal} {{/mux32_1_tb/in[22]} -radix hexadecimal} {{/mux32_1_tb/in[21]} -radix hexadecimal} {{/mux32_1_tb/in[20]} -radix hexadecimal} {{/mux32_1_tb/in[19]} -radix hexadecimal} {{/mux32_1_tb/in[18]} -radix hexadecimal} {{/mux32_1_tb/in[17]} -radix hexadecimal} {{/mux32_1_tb/in[16]} -radix hexadecimal} {{/mux32_1_tb/in[15]} -radix hexadecimal} {{/mux32_1_tb/in[14]} -radix hexadecimal} {{/mux32_1_tb/in[13]} -radix hexadecimal} {{/mux32_1_tb/in[12]} -radix hexadecimal} {{/mux32_1_tb/in[11]} -radix hexadecimal} {{/mux32_1_tb/in[10]} -radix hexadecimal} {{/mux32_1_tb/in[9]} -radix hexadecimal} {{/mux32_1_tb/in[8]} -radix hexadecimal} {{/mux32_1_tb/in[7]} -radix hexadecimal} {{/mux32_1_tb/in[6]} -radix hexadecimal} {{/mux32_1_tb/in[5]} -radix hexadecimal} {{/mux32_1_tb/in[4]} -radix hexadecimal} {{/mux32_1_tb/in[3]} -radix hexadecimal} {{/mux32_1_tb/in[2]} -radix hexadecimal} {{/mux32_1_tb/in[1]} -radix hexadecimal} {{/mux32_1_tb/in[0]} -radix hexadecimal}} -expand -subitemconfig {{/mux32_1_tb/in[31]} {-radix hexadecimal} {/mux32_1_tb/in[30]} {-radix hexadecimal} {/mux32_1_tb/in[29]} {-radix hexadecimal} {/mux32_1_tb/in[28]} {-radix hexadecimal} {/mux32_1_tb/in[27]} {-radix hexadecimal} {/mux32_1_tb/in[26]} {-radix hexadecimal} {/mux32_1_tb/in[25]} {-radix hexadecimal} {/mux32_1_tb/in[24]} {-radix hexadecimal} {/mux32_1_tb/in[23]} {-radix hexadecimal} {/mux32_1_tb/in[22]} {-radix hexadecimal} {/mux32_1_tb/in[21]} {-radix hexadecimal} {/mux32_1_tb/in[20]} {-radix hexadecimal} {/mux32_1_tb/in[19]} {-radix hexadecimal} {/mux32_1_tb/in[18]} {-radix hexadecimal} {/mux32_1_tb/in[17]} {-radix hexadecimal} {/mux32_1_tb/in[16]} {-radix hexadecimal} {/mux32_1_tb/in[15]} {-radix hexadecimal} {/mux32_1_tb/in[14]} {-radix hexadecimal} {/mux32_1_tb/in[13]} {-radix hexadecimal} {/mux32_1_tb/in[12]} {-radix hexadecimal} {/mux32_1_tb/in[11]} {-radix hexadecimal} {/mux32_1_tb/in[10]} {-radix hexadecimal} {/mux32_1_tb/in[9]} {-radix hexadecimal} {/mux32_1_tb/in[8]} {-radix hexadecimal} {/mux32_1_tb/in[7]} {-radix hexadecimal} {/mux32_1_tb/in[6]} {-radix hexadecimal} {/mux32_1_tb/in[5]} {-radix hexadecimal} {/mux32_1_tb/in[4]} {-radix hexadecimal} {/mux32_1_tb/in[3]} {-radix hexadecimal} {/mux32_1_tb/in[2]} {-radix hexadecimal} {/mux32_1_tb/in[1]} {-radix hexadecimal} {/mux32_1_tb/in[0]} {-radix hexadecimal}} /mux32_1_tb/in
add wave -noupdate /mux32_1_tb/out
add wave -noupdate -radix unsigned -expand /mux32_1_tb/sel
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {73718 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {367500 ps}
