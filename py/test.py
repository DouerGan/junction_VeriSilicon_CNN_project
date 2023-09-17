import numpy as np

with open('jct_datain_x8.mem', 'rb') as f:
    data = f.read()                                              #加载文件

image_data = np.frombuffer(data[:67500], dtype=np.int8)
kernel_data = np.frombuffer(data[117500:117527], dtype=np.int8)  #加载数据

image_data = image_data.reshape((150, 150, 3))                   #配置输入层和卷积核
kernel_data = kernel_data.reshape((3, 3, 3))

output_shape = (148, 148, 1)
output = np.zeros(output_shape, dtype=np.int8)                   #特征层

for i in range(output_shape[0]):
    for j in range(output_shape[1]):
        region = image_data[i:i + 3, j:j + 3, :]
        result = np.sum(region * kernel_data, axis=(0, 1, 2))
        output[i, j, :] = result
print(output)
