dir = test_dir
malicious_dir = malicious_dir
interval = 5

run: prebuild
	bash antivirusd.sh $(dir) $(malicious_dir) $(interval)

restore: prebuild
	bash restore.sh $(dir) $(malicious_dir)

prebuild:
	mkdir -p $(malicious_dir) $(dir)

clean:
	rm -f directory-info.last directory-info.new whitelist.txt
