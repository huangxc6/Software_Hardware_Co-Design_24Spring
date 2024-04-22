import serial#导入串口通信库
ser = serial.Serial()

ser.port='com3'
ser.baudrate=115200
ser.bytesize=8
ser.stopbits=1
ser.open()
if(ser.isOpen()):
    print("串口打开成功！")
else:
    print("串口打开失败！")

send_data = "hello world"
len = ser.write(send_data.encode('utf-8')) 
print("send len: ", len)

# 串口接收一个字符串
recv_data = ''
for i in range(len):
    recv_data += ser.read().decode("utf-8")
print("receive data: ", recv_data)
assert recv_data == send_data
ser.close()
