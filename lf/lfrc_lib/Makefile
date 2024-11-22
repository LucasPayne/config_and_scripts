.PHONY: header
header:
	>header
	echo "# NOTE: This is auto-generated. Do not edit." >> header
	fd -a -d1 -tf -elf | xargs -i echo 'source {}' >> header
	fd -a -d1 -tf -elf | xargs git add

default:
	header
