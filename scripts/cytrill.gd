extends Node

func set_led(js, led, red, green, blue, brightness):
	var data = RawArray()

	data.push_back(0x20 + led)
	data.push_back(red)
	data.push_back(green)
	data.push_back(blue)
	data.push_back(brightness)
	data.push_back(0x20 + led)

	var udp = PacketPeerUDP.new()
	print(Input.get_joy_name(js))
	
	var host = Input.get_joy_name(js).split(":")[1]
	var port = 1337

	var status = udp.set_send_address(host, port)

	if status == OK:
		udp.put_packet(data)
	
	udp.close()

func get_name(js):
	return Input.get_joy_name(js).split(":")[0]
