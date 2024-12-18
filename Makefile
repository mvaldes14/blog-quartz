sync:
	rsync -r /mnt/c/Users/migue/Documents/wiki/Blog/ content
	npx quartz sync

clean:
	rm -rf public

