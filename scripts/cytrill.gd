extends Node

func get_ip(js):
	var splitted_name = Input.get_joy_name(js).split(":")

	if splitted_name.size() == 2:
		return splitted_name[1]
	else:
		return null

func set_led(js, led, red, green, blue, brightness):
	var data = RawArray()

	data.push_back(0x20 + led)
	data.push_back(red)
	data.push_back(green)
	data.push_back(blue)
	data.push_back(brightness)
	data.push_back(0x20 + led)

	var udp = PacketPeerUDP.new()

	var ip = get_ip(js)
	var port = 1337

	if ip != null:
		var status = udp.set_send_address(ip, port)

		if status == OK:
			udp.put_packet(data)

		udp.close()

func get_name(js):
	var splitted_name = Input.get_joy_name(js).split(":")

	if splitted_name.size() == 2:
		return splitted_name[0]
	else:
		return Input.get_joy_name(js)
