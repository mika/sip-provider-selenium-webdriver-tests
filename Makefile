all: test

test:
	bundle exec rspec run_tests.rb

html:
	bundle exec rspec --format html run_tests.rb > report.html

install:
	bundle install --path=bundled --binstubs

local-install:
	bundle install --path=bundled --local --binstubs

# note: you need to adjust that according to your needs
selenium:
	java -jar /var/lib/selenium/selenium-server.jar -debug \
		-trustAllSSLCertificates -proxyInjectionMode
	# e.g. with xvfb running on :99 for headless setup within Jenkins
	# DISPLAY=:99 /usr/lib/jvm/java-6-sun/jre/bin/java -jar \
	#             /var/lib/selenium/selenium-server.jar -debug \
	#	      -trustAllSSLCertificates -proxyInjectionMode
