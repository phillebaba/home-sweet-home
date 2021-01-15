FQBN=arduino:avr:uno
PORT=/dev/ttyACM0

build:
	arduino-cli compile --fqbn $(FQBN)

upload: build
	arduino-cli upload --fqbn $(FQBN) --port $(PORT)
