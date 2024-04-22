import serial#导入串口通信库
ser = serial.Serial()

ser.port='com5'
ser.baudrate=115200
ser.bytesize=8
ser.stopbits=1
ser.open()
if(ser.isOpen()):
    print("串口打开成功！")
else:
    print("串口打开失败！")

# 串口循环发送一个字节的数字，从0-255
for i in range(256):
    len = ser.write(bytes([i]))

    high_i = i >> 4
    low_i = i & 0x0f
    result = high_i * low_i

    recv_data = ser.read()
    recv_data = int.from_bytes(recv_data, byteorder='big')
    # 打印发送的数字高四位与低四位相乘的结果

    print("{} * {} = {}".format(high_i, low_i, recv_data))
    assert(recv_data == result)

ser.close()
