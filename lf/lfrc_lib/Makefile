.PHONY: header
header:
	>header
	fd -a -d1 -tf -elf | xargs -i echo 'source {}' >> header
	fd -a -d1 -tf -elf | xargs git add

default:
	header
