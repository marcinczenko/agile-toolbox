import subprocess
import sys

def execute_command(cmd):
	print cmd
	if preview_only:
		return
	try:
		output = subprocess.check_output(cmd.split(' '))
	except subprocess.CalledProcessError as err:
		print 'ERROR:',err
		sys.exit(0)
	else:
		if 0 != len(output):
			print output

preview_only = False

execute_command("sudo python /Users/marcin/Projects/Quantum/AgileToolbox/GoogleAppEngineAppMock/main.py -n 5")
