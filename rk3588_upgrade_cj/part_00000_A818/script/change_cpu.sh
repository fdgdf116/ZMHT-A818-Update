echo performance > /sys/devices/system/cpu/cpufreq/policy6/scaling_governor 
echo performance > /sys/devices/system/cpu/cpufreq/policy4/scaling_governor
echo performance > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq