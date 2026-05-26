transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/TFM/Proyectos_Quartus/PID/Scripts {D:/TFM/Proyectos_Quartus/PID/Scripts/UCC.v}
vlog -vlog01compat -work work +incdir+D:/TFM/Proyectos_Quartus/PID/Scripts {D:/TFM/Proyectos_Quartus/PID/Scripts/Sensor_receiver.v}
vlog -vlog01compat -work work +incdir+D:/TFM/Proyectos_Quartus/PID/Scripts {D:/TFM/Proyectos_Quartus/PID/Scripts/PWM_gen.v}
vlog -vlog01compat -work work +incdir+D:/TFM/Proyectos_Quartus/PID/Scripts {D:/TFM/Proyectos_Quartus/PID/Scripts/PISO.v}
vlog -vlog01compat -work work +incdir+D:/TFM/Proyectos_Quartus/PID/Scripts {D:/TFM/Proyectos_Quartus/PID/Scripts/PID.v}
vlog -vlog01compat -work work +incdir+D:/TFM/Proyectos_Quartus/PID/Scripts {D:/TFM/Proyectos_Quartus/PID/Scripts/LUTP.v}
vlog -vlog01compat -work work +incdir+D:/TFM/Proyectos_Quartus/PID/Scripts {D:/TFM/Proyectos_Quartus/PID/Scripts/LUTI.v}
vlog -vlog01compat -work work +incdir+D:/TFM/Proyectos_Quartus/PID/Scripts {D:/TFM/Proyectos_Quartus/PID/Scripts/LUTD2.v}
vlog -vlog01compat -work work +incdir+D:/TFM/Proyectos_Quartus/PID/Scripts {D:/TFM/Proyectos_Quartus/PID/Scripts/LUTD1.v}
vlog -vlog01compat -work work +incdir+D:/TFM/Proyectos_Quartus/PID/Scripts {D:/TFM/Proyectos_Quartus/PID/Scripts/Delay.v}
vlog -vlog01compat -work work +incdir+D:/TFM/Proyectos_Quartus/PID/Scripts {D:/TFM/Proyectos_Quartus/PID/Scripts/ACC_adder.v}
vlog -vlog01compat -work work +incdir+D:/TFM/Proyectos_Quartus/PID/Scripts {D:/TFM/Proyectos_Quartus/PID/Scripts/ACC.v}

vlog -vlog01compat -work work +incdir+D:/TFM/Proyectos_Quartus/PID/simulation/Scripts {D:/TFM/Proyectos_Quartus/PID/simulation/Scripts/Receptor_Datos.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneiii_ver -L rtl_work -L work -voptargs="+acc"  Receptor_Datos

add wave *
view structure
view signals
run -all
