import os

syncs = open("sync.conf")
directory_pairs = []
file_pairs = []

chomping_dirs = False
for line in syncs.readlines():
	if line.strip() == "Directories":
		chomping_dirs = True
	elif line.strip() == "Files":
		chomping_dirs = False
	elif chomping_dirs:
		directory_pairs.append([val.strip() for val in line.split("::")])
	else:
		file_pairs.append([val.strip() for val in line.split("::")])

# for pair in directory_pairs:
# 	print("Directory pair: {} {}".format(*pair))
# for pair in file_pairs:
# 	print("File pair: {} {}".format(*pair))

class Client:
	name = ""
	path = ""
	directory_lines = []
	file_lines = []
	def __init__(self):
		self.directory_lines = []
		self.file_lines = []

clients_file = open(os.path.expanduser("sync-clients.conf"))
clients = []

# Text processing
blocks = []
cur_lines = []
lines = clients_file.readlines()
for (i, line) in enumerate(lines):
	if line.strip() == "":
		# Found separator
		blocks.append(cur_lines)
		cur_lines = []
	elif i == len(lines) - 1:
		# Found EOF
		cur_lines.append(line)
		blocks.append(cur_lines)
		cur_lines = []
	else:
		# Eating lines to process as a block
		cur_lines.append(line)

for block in blocks:
	new_client = Client()
	new_client.name, new_client.path = [val.strip() for val in block[0].split(" :: ")]
	chomping_dirs = False
	for line in block[1:]:
		if line.strip() == "Directories":
			chomping_dirs = True
		elif line.strip() == "Files":
			chomping_dirs = False
		elif chomping_dirs:
			new_client.directory_lines.append(line)
		else:
			new_client.file_lines.append(line)
	clients.append(new_client)

# Work with the client files

for client in clients:
	print("Syncing hotkeys with {}...".format(client.name))
	if os.path.isfile(os.path.expanduser(client.path)): os.remove(client.path)
	f = open(client.path, 'w+')
	print("\tSyncing directory hotkeys for {}...".format(client.name))
	for line in client.directory_lines:
		for pair in directory_pairs:
			try:
				f.write(line.format(*pair))
			except:
				print("Error at " + line + " with pair " + str(pair))
			print("\t\t"+line.format(*pair), end="")
	print("\tSyncing file hotkeys for {}...".format(client.name))
	for line in client.file_lines:
		for pair in file_pairs:
			try:
				f.write(line.format(*pair))
			except:
				print("Error at " + line + " with pair " + str(pair))
			print("\t\t"+line.format(*pair), end="")

