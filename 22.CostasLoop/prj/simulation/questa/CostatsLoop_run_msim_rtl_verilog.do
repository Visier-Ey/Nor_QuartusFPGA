transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+/home/visier/WorkSpace/FPGA_Porject/VisierCustom/22.CostasLoop/prj/ipcore/pll {/home/visier/WorkSpace/FPGA_Porject/VisierCustom/22.CostasLoop/prj/ipcore/pll/pll.v}
vlog -vlog01compat -work work +incdir+/home/visier/WorkSpace/FPGA_Porject/VisierCustom/22.CostasLoop/prj/ipcore/rom {/home/visier/WorkSpace/FPGA_Porject/VisierCustom/22.CostasLoop/prj/ipcore/rom/rom_256x8b.v}
vlog -vlog01compat -work work +incdir+/home/visier/WorkSpace/FPGA_Porject/VisierCustom/22.CostasLoop/prj/db {/home/visier/WorkSpace/FPGA_Porject/VisierCustom/22.CostasLoop/prj/db/pll_altpll.v}
vlog -sv -work work +incdir+/home/visier/WorkSpace/FPGA_Porject/VisierCustom/22.CostasLoop/rtl {/home/visier/WorkSpace/FPGA_Porject/VisierCustom/22.CostasLoop/rtl/_NCO.sv}
vlog -sv -work work +incdir+/home/visier/WorkSpace/FPGA_Porject/VisierCustom/22.CostasLoop/rtl {/home/visier/WorkSpace/FPGA_Porject/VisierCustom/22.CostasLoop/rtl/_NCO_Variant.sv}
vlog -sv -work work +incdir+/home/visier/WorkSpace/FPGA_Porject/VisierCustom/22.CostasLoop/rtl {/home/visier/WorkSpace/FPGA_Porject/VisierCustom/22.CostasLoop/rtl/Costas.sv}
vlog -sv -work work +incdir+/home/visier/WorkSpace/FPGA_Porject/VisierCustom/22.CostasLoop/rtl {/home/visier/WorkSpace/FPGA_Porject/VisierCustom/22.CostasLoop/rtl/FIR.sv}
vlog -sv -work work +incdir+/home/visier/WorkSpace/FPGA_Porject/VisierCustom/22.CostasLoop/rtl {/home/visier/WorkSpace/FPGA_Porject/VisierCustom/22.CostasLoop/rtl/loop_filter.sv}
vlog -sv -work work +incdir+/home/visier/WorkSpace/FPGA_Porject/VisierCustom/22.CostasLoop/rtl {/home/visier/WorkSpace/FPGA_Porject/VisierCustom/22.CostasLoop/rtl/mixer.sv}
vlog -sv -work work +incdir+/home/visier/WorkSpace/FPGA_Porject/VisierCustom/22.CostasLoop/rtl {/home/visier/WorkSpace/FPGA_Porject/VisierCustom/22.CostasLoop/rtl/CostasTop.sv}

vlog -vlog01compat -work work +incdir+/home/visier/WorkSpace/FPGA_Porject/VisierCustom/22.CostasLoop/prj/../sim {/home/visier/WorkSpace/FPGA_Porject/VisierCustom/22.CostasLoop/prj/../sim/costas.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  costas

add wave *
view structure
view signals
run -all
